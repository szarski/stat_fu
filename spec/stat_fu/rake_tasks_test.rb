require File.dirname(__FILE__) + '/../spec_helper.rb'
 
describe "rake tasks test -> " do

  before(:all) do
    # load rake tasks
    require 'rake'
    RAILS_ROOT = File.join(File.dirname(__FILE__), '..', 'dummy_code')
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require File.join(File.dirname(__FILE__), '../', '../', 'tasks', 'stat_fu_tasks')
    Rake::Task.define_task(:environment)
  end

  it "should add rake tasks" do
    @rake['stats:foo:hardcore:count'].should_not be_nil
  end


end
