module Statistic

  @rake_tasks = {}

  def self.add_rake_task(task_name, options)
    @rake_tasks[task_name.to_sym] = options
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
      stat = self.new(options)
      stat.count_and_check
      if stat.save
        return stat
      else
        return false
      end
    end

    def self.find_by_parameters(options={})
      options.each {|option, value| options.delete(option) unless self.parameter_list.include?(option)}
      stat = self.find :first, :conditions => options
    end

    def self.update(options={})
      stat = self.find_by_parameters options
      if stat
        stat.count_and_check
        return stat.save ? stat : false
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
      super()
      raise Statistic::Errors::BasicMethodsMissing.new unless (self.respond_to?(:count) and self.respond_to?(:check))
      self.class.parameter_list.each do |parameter_name|
        raise Statistic::Errors::ParameterNotSpecified.new(parameter_name, self.class) unless options.has_key?(parameter_name)
        value = options.delete parameter_name
        self.send "#{parameter_name}=".to_sym, value
      end
    end

    def count_and_check
      self.count
      self.coherent = self.check
      return self.coherent
    end

    def self.rake_tasks
      unless block_given?
        raise Exception.new 'rake_tasks method takes a block'
      end
      tasks_wrapper = RakeTaskWrapper.new(self)
      yield tasks_wrapper
    end

    class RakeTaskWrapper
      attr_accessor :klass, :namespaces
      def initialize(klass, _namespaces=nil)
        self.klass = klass
        self.namespaces = _namespaces || [klass.name.underscore.gsub(/^.*\//,'').to_sym]
      end

      def namespace(name)
        yield self.class.new(self.klass, self.namespaces + [name])
      end

      def method_missing(task_name, description=nil)
        code_block = lambda{yield}
        Statistic.add_rake_task task_name, :description => description, :block => code_block, :namespaces => self.namespaces
      end
    end
  end
end
