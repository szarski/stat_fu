class Bar < Statistic::Base
  set_table_name "foo"
  parameters :day, :color

  def count
    self.output = "color for the day #{self.day} is #{self.color}"
  end

  def check
    self.output.include? self.day.to_s
  end

  def self.count_test
  end

  def self.count_hardcore_test
  end

  rake_tasks do |r|
    r.namespace :bar do |b|
      b.namespace :hardcore do |n|
        n.count "count hardcore stuff" do
          Bar.count_hardcore_test
        end
      end
      b.count "count normal stuff" do
        Bar.count_test
      end
    end
  end
end
