require File.dirname(__FILE__) + '/../spec_helper.rb'
 
describe "RAKE TASKS TEST -> " do

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
    @rake['stats:bar:hardcore:count'].should_not be_nil
    @rake['stats:bar:count'].should_not be_nil
  end

  it "tasks should work" do
    pending
  # Bar.should_receive(:count)
  # Bar.should_receive(:count_hardcore)
  # @rake['stats:bar:hardcore:count'].invoke
  # @rake['stats:bar:count'].invoke
  end


end
