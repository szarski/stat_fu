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
    specification = Statistic::RakeTaskSpecification.new(task_name, :description => description, :block => code_block, :namespaces => self.namespaces, :klass_name => klass.name)
    Statistic.add_rake_task specification
  end

  def default_update(method_name, description, params_spec)
    self.send method_name, description do
      params_spec = params_spec.inject({}) {|sum, (k,v)| v=v.is_a?(Proc) ? v.call : v ;sum.merge({k=>v})}
      klass.batch(params_spec).fill_up {|stat| puts "  #{stat.coherent ? '+' : '!'}  #{stat.class} for: #{stat.parameters}"}
    end
  end

  def default_clear(method_name, description=nil)
    self.send method_name, description do
      klass.delete_all
      if klass.count == 0
        puts "deleted all"
      else
        puts "ERROR!"
      end
    end
  end
end
