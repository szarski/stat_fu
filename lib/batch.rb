module Statistic

  class Batch
    attr_reader :klass, :params_spec, :records, :combinations, :satisfied_combinations, :unsatisfied_combinations, :force

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
      #@records = @combinations.collect {|params| self.klass.find_by_parameters params}.compact
      @records = self.klass.find :all, :conditions => @params_spec
      if @records.first and @records.first.respond_to?(:up_to_date?)
        @satisfied_combinations = @records.select {|r| r.batch = self; r.up_to_date?}.map &:parameters
      else
        @satisfied_combinations = @records.map &:parameters
      end
      @satisfied_combinations = @satisfied_combinations.collect {|combination| @params_spec.keys.inject({}) {|result, key| result.merge({key => combination[key]})} }
      @unsatisfied_combinations = @combinations - @satisfied_combinations
    end

    def fill_up(&block)
      self.reload
      collection = @force ? @combinations : @unsatisfied_combinations
      collection.each do |params|
        params.merge!({:force => true}) if @force
        stat = self.klass.create_or_update params, self
        if block_given?
          block.call(stat)
        end
      end
      self.reload
    end

    def cached_value?(name)
      @cached_values.keys.include? name
    end

    def cached_value(name)
      @cached_values[name]
    end

    def cache_value(name, value)
      @cached_values[name] = value
      return value
    end

  end
end
