module Statistic

  class Batch
    attr_reader :klass, :params_spec, :force
    attr_reader :combinations, :satisfied_combinations, :unsatisfied_combinations, :outdated_combinations, :empty_combinations
    attr_reader :records, :outdated_records

    def initialize(klass, params_spec)
      @klass = klass
      @force = params_spec.delete :force
      @params_spec = self.klass.fish_and_test_parameters params_spec, true
      @combinations = []
      @params_spec.each_combination do |params|
        @combinations << params
      end
      @cached_values = {}
      @records = []
      self.reload
    end

    def total_nitems
      return @combinations.nitems
    end

    def existing_nitems
      return  @records.nitems
    end

    def full?
      return @records.nitems == @combinations.nitems
    end

    def reload
      @cached_values = {}
      @cached_values_times = {}
      @records = self.klass.find :all, :conditions => @params_spec
      @outdated_records = []
      if @records.first and @records.first.respond_to?(:up_to_date?)
        @satisfied_combinations = []
        @records.each {|r| r.batch = self; r.up_to_date? ? (@satisfied_combinations << r.parameters) : (@outdated_records << r)}.compact
        @outdated_combinations = @outdated_records.collect {|r| r.parameters}
      else
        @satisfied_combinations = @records.map &:parameters
        @outdated_combinations = []
      end
      @satisfied_combinations = @satisfied_combinations.collect {|combination| @params_spec.keys.inject({}) {|result, key| result.merge({key => combination[key]})} }
      @unsatisfied_combinations = @combinations - @satisfied_combinations
      @empty_combinations =  @unsatisfied_combinations - @outdated_combinations
    end

    def fill_up(&block)
      self.reload
      collection = @force ? @records : @outdated_records
      collection.each do |record|
        record.count_and_check
        record.save
        if block_given?
          block.call(record)
        end
      end
      @empty_combinations.each do |params|
        stat = self.klass.create params, self
        if block_given?
          block.call(stat)
        end
      end
      self.reload
    end

    def cached_value?(name)
      @cached_values_times[name] ? true : false
    end

    def cached_value(name)
      @cached_values[name]
    end

    def cache_value(name, value)
      @cached_values_times[name] = Time.now
      @cached_values[name] = value
      return value
    end

  end
end
