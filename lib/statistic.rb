module Statistic

  @rake_tasks = []

  def self.add_rake_task(task_specification)
    @rake_tasks << task_specification
  end

  def self.rake_tasks
    @rake_tasks
  end

  def self.rake_tasks_by_klass_name
    @rake_tasks.inject({}) {|result, s| result[s.klass_name] ||= []; result[s.klass_name] << s; result}
  end

  class Base < ActiveRecord::Base

    named_scope :coherent, :conditions => {:coherent => 1}
    named_scope :not_coherent, :conditions => {:coherent => 0}

    attr_accessor :batch

    def self.parameters(*parameter_list)
      @output_klass = Class.new(::Statistic::Batch)
      @optional_parameter_list = []
      if parameter_list.is_a?(Array) and parameter_list.last.is_a?(Hash)
        options = parameter_list.pop
        if options[:optional]
          @optional_parameter_list = options[:optional]
        end
      end
      raise Statistic::Errors::InvalidParameterList.new unless (parameter_list.is_a?(Array) and parameter_list.collect{|x|x.class}.uniq == [Symbol])
      @parameter_list = parameter_list.clone
      if parameter_list.size == 0
      elsif parameter_list.size == 1
        validates_uniqueness_of parameter_list.pop, :message => "There already is a statistic for given parameters!"
      else
        validates_uniqueness_of parameter_list.pop, :scope => parameter_list, :message => "There already is a statistic for given parameters!"
      end
    end

    def self.create(options={}, batch=nil)
      options.delete :force
      stat = self.new(options)
      stat.batch = batch
      stat.count_and_check
      if stat.save
        return stat
      else
        return false
      end
    end

    def self.find_by_parameters(options={}, batch=nil)
      valid_options = options.clone
      options.each {|option, value| valid_options.delete(option) unless self.parameter_list.include?(option)}
      stat = self.find :first, :conditions => valid_options
      stat.batch = batch unless batch.nil?
      return stat
    end

    def self.update(options={}, batch=nil)
      force = options.delete :force
      stat = self.find_by_parameters options
      if stat
        stat.batch = batch
        if !force and stat.respond_to?(:up_to_date?) and stat.up_to_date?
          return stat
        else
          stat.count_and_check
          return stat.save ? stat : false
        end
      else
        return nil
      end
    end

    def self.create_or_update(options={}, batch=nil)
      if self.find_by_parameters options
        return self.update(options, batch)
      else
        result = self.create(options, batch)
      end
      return result
    end

    def self.parameter_list
      @parameter_list
    end

    def self.optional_parameter_list
      @optional_parameter_list
    end

    def self.fish_and_test_parameters(options, for_collections=false)
      proper_parameters = {}
      self.parameter_list.each do |parameter_name|
        raise Statistic::Errors::ParameterNotSpecified.new(parameter_name, self) unless (options.has_key?(parameter_name) or self.optional_parameter_list.include?(parameter_name))
        value = options.delete parameter_name
        column_spec = self.columns_hash[parameter_name.to_s]
        proper_klass = column_spec ? column_spec.klass : nil
        value_klass = value.class
        if for_collections and value_klass == Array
          value_klass = value.map(&:class).uniq
          value_klass = value_klass.nitems < 2 ? value_klass.first : value_klass
        end
        unless (value_klass == proper_klass or value.nil? or proper_klass.nil?)
          raise Statistic::Errors::BadParameterClass.new(parameter_name, proper_klass, value_klass, self)
        end
        proper_parameters[parameter_name] = value
      end
      return proper_parameters
    end

    def initialize(options={})
      raise Statistic::Errors::BasicMethodsMissing.new unless ((self.respond_to?(:count) and self.respond_to?(:check)))
      proper_parameters = self.class.fish_and_test_parameters(options)
      super(options)
      # we have to assing params after super() is called, but we also want to keep the regular super(options) functionality
      proper_parameters.each do |parameter_name, value|
        self.send "#{parameter_name}=".to_sym, value
      end
    end

    def count_and_check
      self.generation_time_seconds = self.class.measure_time do
        self.count
        self.coherent = self.check
      end
      return self.coherent
    end

    def self.rake_tasks
      unless block_given?
        raise Exception.new 'rake_tasks method takes a block'
      end
      tasks_wrapper = RakeTaskWrapper.new(self, [:stats])
      yield tasks_wrapper
    end

    def self.measure_time
      t=Time.now.getutc
      result = yield
      return Time.now.getutc - t
      #return result
    end

    def self.coherence_stat
      c = self.all.map &:coherent
      valid = c.reject {|x| !x}.nitems
      invalid = c.reject {|x| x}.nitems
      total = c.nitems
      valid_percentage = ((total > 0) ? (100 * valid/total) : 100).round
      if valid_percentage == 100 and invalid > 0
        valid_percentage = 99
      end
      return {:valid => valid, :invalid => invalid, :total => total, :valid_percentage => valid_percentage }
    end

    def self.field_list
      field_names = self.columns_hash.keys - %w{id created_at updated_at coherent generation_time_seconds}
      field_names.collect! {|k| k.to_sym}
      field_names = field_names - self.parameter_list
      return {:arguments => self.parameter_list, :values => field_names}
    end

    def self.batch(params_spec)
      return @output_klass.new self, params_spec
    end

    def parameters
      self.class.parameter_list.inject({}) do |result, k|
        value = self.send(k)
        unless self.class.optional_parameter_list.include?(k) and value.nil?
           result[k] = value
        end
        result
      end
    end

    def cache_in_batch(name, &block)
      if self.batch
        if self.batch.cached_value?(name)
          return self.batch.cached_value name
        else
          return self.batch.cache_value name, block.call(self.batch.records)
        end
      else
        return block.call([self])
      end
    end

    def self.describe_output(output_description)
      @output_klass.class_eval do
        output_description.each do |method_name, operation|
          if operation.is_a?(Proc)
            operation_method_name = "stat_fu_operation_#{operation.hash}".to_sym
            define_method operation_method_name, &operation
            define_method method_name do
              self.send operation_method_name, @records
            end
          elsif [:sum, :average, :first, :nitems, :join].include?(operation)
            define_method method_name do
              @records.map(&method_name).send operation
            end
          else
            raise Exception.new('Malformed output specification!')
          end
        end
      end
    end

  end
end
