module Statistic::Errors
  class Base < Exception

  end

  class InvalidParameterList < Base
    def message
      "You have to specify an array of parameters for the statistic as symbols"
    end
  end

  class ParameterNotSpecified < Base
    attr_accessor :parameter_name, :model_klass
    def initialize(parameter_name, model_klass)
      self.parameter_name = parameter_name
      self.model_klass = model_klass
    end
    def message
      "You did not specify all the parameters:\n  #{self.parameter_name} not specified\n  #{self.model_klass.parameter_list.collect{|p| p.to_s}.join(', ')} required"
    end
  end

  class BasicMethodsMissing < Base
    def message
      "Missing basic methods. Statistic_fu requires you to specify at least the count() and check() instance methods for your model"
    end
  end
end
