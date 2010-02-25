module Statistic

  @rake_tasks = []

  def self.add_rake_task(task_name, options)
    @rake_tasks << options.merge({:name => task_name})
  end

  def self.rake_tasks
    @rake_tasks
  end

  class Base < ActiveRecord::Base

    def self.parameters(*parameter_list)
      raise Statistic::Errors::InvalidParameterList.new unless (parameter_list.is_a?(Array) and parameter_list.collect{|x|x.class}.uniq == [Symbol])
      @parameter_list = parameter_list.clone
      if parameter_list.size == 0
      elsif parameter_list.size == 1
        validates_uniqueness_of parameter_list.pop, :message => "There already is a statistic for given parameters!"
      else
        validates_uniqueness_of parameter_list.pop, :scope => parameter_list, :message => "There already is a statistic for given parameters!"
      end
    end

    def self.create(options={})
      options.delete :force
      stat = self.new(options)
      stat.count_and_check
      if stat.save
        return stat
      else
        return false
      end
    end

    def self.find_by_parameters(options={})
      valid_options = options.clone
      options.each {|option, value| valid_options.delete(option) unless self.parameter_list.include?(option)}
      stat = self.find :first, :conditions => valid_options
    end

    def self.update(options={})
      force = options.delete :force
      stat = self.find_by_parameters options
      if stat
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

    def self.create_or_update(options={})
      if self.find_by_parameters options
        return self.update(options)
      else
        result = self.create(options)
      end
      return result
    end

    def self.parameter_list
      @parameter_list
    end

    def initialize(options={})
      proper_parameters = {}
      raise Statistic::Errors::BasicMethodsMissing.new unless (self.respond_to?(:count) and self.respond_to?(:check))
      self.class.parameter_list.each do |parameter_name|
        raise Statistic::Errors::ParameterNotSpecified.new(parameter_name, self.class) unless options.has_key?(parameter_name)
        value = options.delete parameter_name
        proper_klass = self.class.columns_hash[parameter_name.to_s].klass
        value_klass = value.class
        raise Statistic::Errors::BadParameterClass.new(parameter_name, proper_klass, value_klass, self.class) unless value_klass == proper_klass
        proper_parameters[parameter_name] = value
      end
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
      tasks_wrapper = RakeTaskWrapper.new(self)
      yield tasks_wrapper
    end

    def self.measure_time
      t=Time.now.getutc
      result = yield
      return Time.now.getutc - t
      #return result
    end
  end
end
