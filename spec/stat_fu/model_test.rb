require File.dirname(__FILE__) + '/../spec_helper.rb'
 
describe "MODEL TEST -> " do

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
        FooA.new(:day => 1, :color => 'green').should respond_to(:day)
        FooA.new(:day => 1, :color => 'green').should respond_to(:color)
        FooA.new(:day => 1, :color => 'green').should_not respond_to(:whatever)
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

      describe "up_to_date?" do
        before(:all) do
          class FooH < Statistic::Base
            set_table_name "foo"
            parameters :day, :color

            def count
              self.output = "date for the day #{self.day} is #{self.date}, timestamp: #{Time.now.to_f.to_s}"
            end

            def check
              self.output.include? self.day.to_s
            end

            def up_to_date?
              return self.sth
            end
          end
        end

        it "should not save given record is up to date" do
          FooH.create(:day => 1, :color => 'green', :sth => true).should be_a(FooH)
          FooH.count.should == 1
          FooH.last.updated_at.should_not > Foo.last.created_at
          sleep(1)
          FooH.update(:day => 1, :color => 'green').should be_a(FooH)
          FooH.count.should == 1
          FooH.last.updated_at.should_not > Foo.last.created_at
        end

        it "should save given record is up to date but a force option is specified" do
          FooH.create(:day => 1, :color => 'green', :sth => true).should be_a(FooH)
          FooH.count.should == 1
          FooH.last.updated_at.should_not > Foo.last.created_at
          sleep(1)
          FooH.update(:day => 1, :color => 'green', :force => true).should be_a(FooH)
          FooH.count.should == 1
          FooH.last.updated_at.should > Foo.last.created_at
        end

        it "should save given record is not up to date" do
          FooH.create(:day => 1, :color => 'green', :sth => false).should be_a(FooH)
          FooH.count.should == 1
          FooH.last.updated_at.should_not > Foo.last.created_at
          sleep(1)
          FooH.update(:day => 1, :color => 'green').should be_a(FooH)
          FooH.count.should == 1
          FooH.last.updated_at.should > Foo.last.created_at
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
  
    it "should initialize a new instance given valid parameters" do
      foo = Foo.new :day => 1, :color => 'green', :whatever => :something
    end
  
    it "should raise given too less parameters" do
      lambda{foo = Foo.new(:day => 1, :whatever => :something)}.should raise_error(Statistic::Errors::ParameterNotSpecified)
    end
  
    it "should raise when parameter types do not match" do
      class FooE < Statistic::Base
        set_table_name "foo"
        parameters :day, :date
  
        def count
          self.output = "date for the day #{self.day} is #{self.date}"
        end
  
        def check
          self.output.include? self.day.to_s
        end
      end
      FooE.new(:day => 1, :date => Time.now.to_date).should be_a(FooE)
      lambda{foo = FooE.new(:day => 1, :date => Time.now)}.should raise_error(Statistic::Errors::BadParameterClass)
      lambda{foo = FooE.new(:day => 1, :date => 2)}.should raise_error(Statistic::Errors::BadParameterClass)
      lambda{foo = FooE.new(:day => 1, :date => 'Tuesday')}.should raise_error(Statistic::Errors::BadParameterClass)
    end
  
    it "should assing parameters when created" do
      foo = Foo.new :day => 1, :color => 'green', :whatever => :something
      foo.color.should == 'green'
      foo.day.should == 1
    end

    it "should update generation_time_seconds when saved" do
      pending
    # foo = Foo.new :day => 1, :color => 'green', :whatever => :something
    # foo.save!
    # Foo.last.generation_time_seconds.should be_a(Float)
    # Foo.last.generation_time_seconds.should > 0
    end

    it "should assing attr_accessors when created" do
      class FooG < Statistic::Base
        attr_accessor :something
        set_table_name "foo"
        parameters :day, :color
  
        def count
          self.output = "date for the day #{self.day} is #{self.date}, timestamp: #{Time.now.to_f.to_s}"
        end
  
        def check
          self.output.include? self.day.to_s
        end
      end
      stat = FooG.new :day => 1, :color => "green", :something => :whatever
      stat.something.should == :whatever
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
      foo = FooH.create :day => 1, :color => 'green'
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
      foo = FooI.create :day => 1, :color => 'yellow'
      FooI.count.should == 2
      FooI.last.coherent.should be_false
    end
  
  end



end
