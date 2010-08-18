require File.dirname(__FILE__) + '/../spec_helper.rb'
 
describe "BATCH TEST -> " do

  it "should return a batch given valid parameters" do
    batch = Foo.batch :day => (1..10).to_a, :color => 'green'
    batch.klass.should == Foo
  end

  it "should raise when parameters are of invalid type" do
    lambda {batch = Foo.batch :day => (1..10).to_a, :color => 8}.should raise_error(Statistic::Errors::BadParameterClass)
  end

  it "should raise when parameters are missing" do
    lambda {batch = Foo.batch :day => (1..10).to_a}.should raise_error(Statistic::Errors::ParameterNotSpecified)
  end

  describe "basic operations -> " do

    before :each do
      @batch = Foo.batch :day => (1..10).to_a, :color => 'green'
    end

    it "should return the total number of records" do
      @batch.total_nitems.should == 10
    end

    it "should return the number of existing" do
      @batch.total_nitems.should == 10
    end

    it "should get batch records" do
      pending
    end

  end

end
