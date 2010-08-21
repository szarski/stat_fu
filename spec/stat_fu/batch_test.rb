require File.dirname(__FILE__) + '/../spec_helper.rb'
 
describe "BATCH TEST -> " do

  before :each do
    clear_database
  end

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
      class BatchTestFoo < Statistic::Base
        set_table_name "foo"
        def self.test_time=(time)
          @test_time = time
        end
        def self.test_time
          @test_time 
        end
        parameters :day, :color
        def count;true;end
        def check;true;end
        describe_output :foo => lambda{ 123 }, :foo_bar => lambda{ '123' }
        def up_to_date?
          return self.updated_at > self.class.test_time
        end
      end
      BatchTestFoo.create :day => 1, :color => 'green'
      BatchTestFoo.create :day => 2, :color => 'green'
      BatchTestFoo.test_time = Time.now
      sleep(1)
      BatchTestFoo.create :day => 3, :color => 'green'
      BatchTestFoo.create :day => 1, :color => 'red'
      BatchTestFoo.create :day => 2, :color => 'red'
      BatchTestFoo.create :day => 3, :color => 'red'
      @batch = BatchTestFoo.batch :day => (1..10).to_a, :color => 'green'
    end

    it "should return the total number of records" do
      @batch.total_nitems.should == 10
    end

    it "should return the number of existing" do
      @batch.total_nitems.should == 10
    end

    it "should get batch records" do
      @batch.existing_nitems.should == 3
    end

    it "should get missing and expired records" do
      @batch.full?.should be_false
      @batch.existing_nitems.should == 3
      @batch.satisfied_combinations.nitems.should == 1
      @batch.fill_up
      @batch.existing_nitems.should == 10
      @batch.full?.should be_true
      @batch.satisfied_combinations.nitems.should == 10
    end

    it "should allow creating simple result classes" do
      clear_database
      class SomeClass < Statistic::Base
        set_table_name "foo"
        parameters :day, :color, :palette, :optional => [:palette]
        attr_accessor :whatever

        def count
          self.output = "color for the day #{self.day} is #{self.color}, timestamp: #{Time.now.to_f.to_s}"
        end

        def check
          self.output.include? self.day.to_s
        end

        describe_output :output => :sum, :last_output => lambda {|records| records.last.output}, :records_count => lambda {|records| records.count}
      end
      batch = SomeClass.batch :day => (1..10).to_a, :color => 'green'
      batch.respond_to?(:output).should be_true
      batch.fill_up
      batch.records_count.should == 10
      batch.output.should == batch.records.map(&:output).sum
      batch.last_output.should == SomeClass.last.output
    end

    it "should have separate output classes" do
      class SomeClass < Statistic::Base
        set_table_name "foo"
        parameters :x

        def count
          true
        end

        def check
          true
        end

        describe_output :foo => lambda{ 123 }, :foo_bar => lambda{ '123' }
      end
      class SomeOtherClass < Statistic::Base
        set_table_name "foo"
        parameters :y

        def count
          true
        end

        def check
          true
        end

        describe_output :bar => lambda{ 456 }, :foo_bar => lambda{ '456' }
      end
      SomeClass.stub!(:find).and_return([])
      SomeOtherClass.stub!(:find).and_return([])
      foo_batch = SomeClass.batch :x => 1
      bar_batch = SomeOtherClass.batch :y => 1
      foo_batch.class.should_not == bar_batch.class
      foo_batch.foo.should == 123
      foo_batch.foo_bar.should == '123'
      bar_batch.bar.should == 456
      bar_batch.foo_bar.should == '456'
      foo_batch.respond_to?(:bar).should be_false
      bar_batch.respond_to?(:foo).should be_false
    end

  end

end
