require File.dirname(__FILE__) + '/../spec_helper.rb'
 
describe "model test -> " do



  describe "Class methods -> " do
    describe "error handling -> " do
      it "should keep the parameter list" do
        class FooA < Statistic::Base
          set_table_name "foo"
          parameters :day, :color
  
          def count
            self.output = "color for the day #{self.day} is #{self.color}"
          end
  
          def check
            self.output.include? self.day.to_s
          end
        end
        FooA.new(:day => 1, :color => 'green', :whatever => :something).should respond_to(:day)
        FooA.new(:day => 1, :color => 'green', :whatever => :something).should respond_to(:color)
        FooA.new(:day => 1, :color => 'green', :whatever => :something).should_not respond_to(:whatever)
      end
  
      it "should raise if invalid parameter list passed" do
        lambda {
          class FooB < Statistic::Base
            set_table_name "foo"
            parameters :a => :b
  
            def count
              self.output = "color for the day #{self.day} is #{self.color}"
            end
    
            def check
              self.output.include? self.day.to_s
            end
          end
        }.should raise_error(Statistic::Errors::InvalidParameterList)
      end
  
      it "should raise if the count method is not specified" do
        class FooC < Statistic::Base
          set_table_name "foo"
          parameters :day, :color
  
          def check
            self.output.include? self.day.to_s
          end
        end
        lambda { FooC.new :day => 1, :color => 'green' }.should raise_error(Statistic::Errors::BasicMethodsMissing)
      end
  
      it "should raise if the count method is not specified" do
        class FooD < Statistic::Base
          set_table_name "foo"
          parameters :day, :color
  
          def count
            self.output = "color for the day #{self.day} is #{self.color}"
          end
        end
        lambda { FooD.new :day => 1, :color => 'green' }.should raise_error(Statistic::Errors::BasicMethodsMissing)
      end
    end

    describe "basic methods -> " do
      before :each do
        clear_database
      end

      describe "create" do
        it "should save given unique parameters" do
          Foo.create(:day => 1, :color => 'green').should be_a(Foo)
          Foo.count.should == 1
          Foo.last.color.should == 'green'
          Foo.last.day.should == 1
          Foo.create(:day => 1, :color => 'green').should be_false
        end

        it "should raise when called with invalid parameters" do
          lambda{ Foo.create(:day => 1) }.should raise_error
          Foo.count.should == 0
        end

        it "should return false when two stats are with the same parameters" do
          Foo.count.should == 0
          Foo.create(:day => 1, :color => 'green').should be_a(Foo)
          Foo.count.should == 1
          Foo.create(:day => 1, :color => 'green').should be_false
          Foo.count.should == 1
        end
      end

      describe "find_by_parameters" do
        it "should respond to find_by_parameters" do
          Foo.find_by_parameters(:day => 1, :color => 'green').should be_nil
          Foo.create(:day => 1, :color => 'green').should be_a(Foo)
          Foo.find_by_parameters(:day => 1, :color => 'green').should be_a(Foo)
        end
      end

      describe "update" do
        it "should save given record is found" do
          Foo.create(:day => 1, :color => 'green').should be_a(Foo)
          Foo.count.should == 1
          Foo.last.updated_at.should_not > Foo.last.created_at
          sleep(1)
          Foo.update(:day => 1, :color => 'green').should be_a(Foo)
          Foo.count.should == 1
          Foo.last.updated_at.should > Foo.last.created_at
        end

        it "should return nil if there is no stat" do
          Foo.update(:day => 1, :color => 'green').should be_nil
          Foo.count.should == 0
        end

        it "should return false if not saved" do
          Foo.create(:day => 1, :color => 'green').should be_a(Foo)
          stat_mock = mock('foo', {:save => false, :count => true, :check => true, :count_and_check => true, :class => Foo})
          Foo.stub!(:find).and_return(stat_mock)
          Foo.update(:day => 1, :color => 'green').should be_false
        end
      end

      describe "create_or_update" do
        it "should save when no record exists" do
          Foo.count.should == 0
          Foo.create_or_update(:day => 1, :color => 'green').should be_a(Foo)
          Foo.count.should == 1
        end

        it "should save when a record exists" do
          Foo.create(:day => 1, :color => 'green').should be_a(Foo)
          Foo.count.should == 1
          Foo.create_or_update(:day => 1, :color => 'green').should be_a(Foo)
          Foo.count.should == 1
        end

        it "should raise given invalid params" do
          lambda {Foo.create_or_update(:day => 1)}.should raise_error
        end
      end

      it "should respond_to check_again" do
        pending
      end
    end
  end



  describe "Instance methods -> " do
    before :each do
      clear_database
    end
  
    it "should create a new instance given valid parameters" do
      foo = Foo.new :day => 1, :color => 'green', :whatever => :something
    end
  
    it "should raise given too less parameters" do
      lambda{foo = Foo.new(:day => 1, :whatever => :something)}.should raise_error(Statistic::Errors::ParameterNotSpecified)
    end
  
    it "should assing parameters when created" do
      foo = Foo.new :day => 1, :color => 'green', :whatever => :something
      foo.color.should == 'green'
      foo.day.should == 1
    end

    it "should allow creating more instances given at least one parameter is unique" do
      foo = Foo.new :day => 1, :color => 'green', :whatever => :something
      foo.save.should be_true
      foo = Foo.new :day => 2, :color => 'green', :whatever => :something
      foo.save.should be_true
      foo = Foo.new :day => 2, :color => 'yellow', :whatever => :something
      foo.save.should be_true
    end

    it "should not allow creating more for the same set of parameters" do
      foo = Foo.new :day => 1, :color => 'green', :whatever => :something
      foo.save.should be_true
      foo = Foo.new :day => 1, :color => 'green', :whatever => :something_else
      foo.save.should be_false
    end

    it "should count the coherent flag when using count_and_check" do
      foo = Foo.new :day => 1, :color => 'green', :whatever => :something_else
      foo.coherent.should be_nil
      foo.count
      foo.coherent.should be_nil
      foo.count_and_check
      foo.coherent.should be_true
      foo.coherent = nil
      foo.coherent.should be_nil
      foo.check
      foo.coherent.should be_nil
    end
  
    it "should save the coherent flag based on the check() method" do
      class FooH < Statistic::Base
        set_table_name "foo"
        parameters :day, :color

        def count
          self.output = "color for the day #{self.day} is #{self.color}"
        end
  
        def check
          true
        end
      end
      foo = FooH.create :day => 1, :color => 'green', :whatever => :something_else
      FooH.count.should == 1
      FooH.last.coherent.should be_true

      class FooI < Statistic::Base
        set_table_name "foo"
        parameters :day, :color

        def count
          self.output = "color for the day #{self.day} is #{self.color}"
        end
  
        def check
          false
        end
      end
      foo = FooI.create :day => 1, :color => 'yellow', :whatever => :something_else
      FooI.count.should == 2
      FooI.last.coherent.should be_false
    end
  
  end



end