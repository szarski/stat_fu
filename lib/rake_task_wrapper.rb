class Statistic::RakeTaskWrapper
  attr_accessor :klass, :namespaces
  def initialize(klass, _namespaces=nil)
    self.klass = klass
    self.namespaces = _namespaces || [] #[klass.name.underscore.gsub(/^.*\//,'').to_sym]
  end

  def namespace(name)
    yield self.class.new(self.klass, self.namespaces + [name])
  end

  def method_missing(task_name, description=nil)
    code_block = lambda{yield}
    specification = Statistic::RakeTaskSpecification.new(task_name, :description => description, :block => code_block, :namespaces => self.namespaces)
    Statistic.add_rake_task specification
  end
end
