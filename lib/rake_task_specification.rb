class Statistic::RakeTaskSpecification
  attr_accessor :name, :namespaces, :block, :description

  def initialize(name, options={})
    self.name = name
    self.namespaces = options[:namespaces].is_a?(Array) ? options.delete(:namespaces) : []
    self.block = options.delete(:block) || lambda{}
    self.description = options.delete(:description)
  end

  def call_creating_method
    specification = self
    add_task = lambda{
      desc(specification.description) unless specification.description.nil?
      task specification.name => :environment do
        specification.block.call
      end
    }
    calls = [add_task]
    self.namespaces.reverse.each_with_index do |name, index|
      calls[index+1] = lambda{
        namespace name do
          calls[index].call
        end
      }
    end
    calls.last.call
  end

  def to_s
    "rake #{self.namespaces.join(':')}#{self.namespaces.empty? ? '' : ':'}#{self.name}"
  end

end
