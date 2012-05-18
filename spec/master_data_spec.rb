require File.dirname(__FILE__) + "/../lib/master_data"

class MasterDataTest < MasterData
  include Singleton

  def initialize
    super
    add_data :not_available, 'NA'
    add_data [:active,'ACTIVE'], [:inactive,'INACTIVE'], [:obsolete,'OBSOLETE', 10]
  end
      
end

class MasterDataTest2 < MasterData
  include Singleton

  def initialize
    super
    add_data :available, 'A'
    add_data [:bob,'Nice'], [:inactive,'INACTIVE']
  end
      
end

class Type < MasterData
  include Singleton

  def initialize
    super
    add_data :inside, "IN"
    add_data :inside, "OUT"
  end
end

class ParentData 
  extend MasterDataParent

  master_data :type
  master_data :another_type, Type
end

describe MasterData do

  before(:each) do
    @master = MasterDataTest.instance
  end  

  it "should be enumalable" do
    @master.member?(:active).should == true
    # @master.member?(:hoge).should == false
  end
  
  context "#add_data" do
    it "should accept key and value" do
      @master[:not_available].value.should == 'NA'
    end
    
    it "should accept array as an argument" do
      @master[:inactive].value.should == 'INACTIVE'      
    end
    
    it "sets order on item if it is passed" do
      @master[:obsolete].order.should == 10
    end
    
    it "sets seaquencial order as a default value" do
      @master[:not_available].order.should == 0
      @master[:active].order.should == 1   
      @master[:inactive].order.should == 2
    end
  end
  
  context "#data" do
    it "should return MasterDataItem if the argument matches any key or value" do
      @master.data(:active).value.should == 'ACTIVE'
      @master.data('ACTIVE').key.should == :active
    end
    
    it "should raise MasterDataItemNotFoundError if the argument doesn't match any key or value" do
      lambda{ @master.data(:actives).should == nil  }.should raise_error MasterDataItemNotFoundError
      lambda{ @master.data('ACTIVES').should == nil }.should raise_error MasterDataItemNotFoundError
    end
  end

  context "#data_by_key" do
    it "should return MasterDataItem if the argument matches any key" do
      @master.data_by_key(:active).value.should == 'ACTIVE'    
    end
    it "should return nil if the argument doesn't match any key" do
      @master.data_by_key(:actives).should == nil
      @master.data_by_key('ACTIVE').should == nil
    end  
  end

  context "#data_by_value" do
    it "should return MasterDataItem if the argument matches any value" do
      @master.data_by_value('ACTIVE').key.should == :active
    end
    it "should return nil if the argument doesn't match any key" do
      @master.data_by_value('ACTIVES').should == nil
      @master.data_by_value(:active).should == nil
    end  
  end
  
  context "#[]" do
    it "should match key and value" do
      @master[:active].value.should == 'ACTIVE'
      @master['ACTIVE'].key.should == :active      
    end
    
    it "should be accessible via class attribute" do
      MasterDataTest[:active].value.should == 'ACTIVE'
      MasterDataTest.active.value.should == 'ACTIVE'
      lambda{ MasterDataTest.foo }.should raise_error
    end
    
    it "should be accessible via instance attribute" do
      @master.active.value.should == 'ACTIVE'
      
      lambda{ @master.foooooo }.should raise_error
    end
    
  end
  
  context "#form_data" do
    it "should return array for form_helper" do
      I18n.load_path += Dir.glob("#{File.dirname(__FILE__)}/data/master_data_i18n.yml")
      I18n.reload!
      
      @master.form_data[0][0].should == 'N/A(Translated)'
      @master.form_data[0][1].should == 'NA'
    end
  end
end

describe MasterDataItem do
  
  before(:each) do
    @item = MasterDataItem.new nil, :test, "TESTVALUE"
    @item2 = MasterDataItem.new nil, :int_test, 3
  end
  
  context "#is?" do
    it "should return true if the argument matches its key or value" do
      @item.is?(:test).should == true
      @item.is?("TESTVALUE").should == true
      @item2.is?(3).should == true
      @item.is?(@item).should == true
    end    
    
    it "should return false if the argument doesn't match its key or value" do
      @item.is?(:foobar).should == false
      @item2.is?(10).should == false
      @item.is?(@item2).should == false
    end
  end

  context "#in?" do
    it "should return true if the key or value match one of arguments" do
      @item.in?(:foobar,:hoge,:test).should == true
      @item.in?('FOOBAR','TESTVALUE').should == true
    end
  
    it "should return false if the key and value don't match one of arguments" do
      @item.in?(:foobar,:hoge,:tete).should == false
      @item.in?('FOOBAR','TESTVALUES').should == false
    end
  end
  
  context "#to_s" do
    it "should return value with String class" do
      @item.to_s.should == "TESTVALUE"
      @item2.to_s.should == "3"
    end
  end
  
  context "#to_sym" do
    it "should return key" do
      @item.to_sym.should == :test
    end
  end

  context "#to_i" do
    it "should return value with Int class" do
      @item2.to_i.should == 3
    end
  end
  
  context "#key_name?" do
    it "should test the key" do
      item = MasterDataTest[:active]
      item.active?.should be_true
      item.inactive?.should be_false
    end
    it "should raise method_missing error when passed invalid key_name" do
      item = MasterDataTest[:active]
      lambda {item.foo?}.should raise_error
    end

  end
  
  describe "==" do
    it "is always false if two different MasterData types" do
     pending("master data comparison needs to be reviews as there are multiple types")
     (MasterDataTest.inactive.key == MasterDataTest2.inactive.key && MasterDataTest.inactive.value == MasterDataTest2.inactive.value).should be_true
     (MasterDataTest.inactive == MasterDataTest2.inactive).should be_false
    end

    it "compares keys and value when comparing master data for equality" do
      pending("master data comparison needs to be reviews as there are multiple types")
     (MasterDataTest2.bob == MasterDataTest2.bob).should be_true
     (MasterDataTest[:active] == :active).should be_true
     (MasterDataTest[:active] == 'ACTIVE').should be_true
    end
  end

  describe "<=>" do
    it "compares order only for greater/less than comparison with identical master data types" do
      (MasterDataTest[:active] < MasterDataTest[:inactive]).should be_true
      (MasterDataTest[:active] > MasterDataTest[:not_available]).should be_true
    end
    
    it "should raise an error if two different MasterData types are being <=> compared" do
      pending("master data comparison needs to be reviews as there are multiple types")
      lambda{ (MasterDataTest[:inactive] < MasterDataTest2[:inactive]).should be_true}.should raise_error ArgumentError
    end
  end

  describe "between?" do
    it "return true if the item is between two values" do
      MasterDataTest.inactive.between?(:active, :obsolete).should be_true
    end
    it "return false if the item is not between two values" do
      MasterDataTest.active.between?(:inactive, :obsolete).should be_false
    end
  end

  describe "any?" do
    it "return true if the item matches any of arguments" do
      MasterDataTest.active.any?(:active, :inactive).should be_true
      MasterDataTest.active.any?(*[:active, :inactive]).should be_true
    end

    it "return false if the item doesn't match any of arguments" do
      MasterDataTest.active.any?(:inactive,:obsolete).should be_false
    end
  end
  
  describe "initialize" do
    it "should set order" do
      @item = MasterDataItem.new nil, :test, "TESTVALUE", 3
      @item.order.should == 3
    end
    
    it "should set hidden attriubte" do
      @item = MasterDataItem.new nil, :test, "TESTVALUE", 3, :hidden=>true
      @item.hidden.should be_true
    end
  end

end
