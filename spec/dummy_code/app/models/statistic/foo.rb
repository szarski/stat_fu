class Foo < Statistic::Base
  set_table_name "foo"
  parameters :day, :color

  def count
    self.output = "color for the day #{self.day} is #{self.color}"
  end

  def check
    self.output.include? self.day.to_s
  end

  rake_tasks do |r|
    r.namespace :hardcore do |n|
      n.count "count hardcore stuff" do
      end
    end
  end
end
