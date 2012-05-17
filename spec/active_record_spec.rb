require "active_record"

require File.dirname(__FILE__) + "/../lib/master_data"
require File.dirname(__FILE__) + "/../lib/master_data/active_record"
require File.dirname(__FILE__) + "/support/active_record"

class PersonType < MasterData
  include Singleton

  def initialize
    super
    add_data :person, "Person"
    add_data :cat, "Cat"
  end
end

class Person < ActiveRecord::Base
  master_data :person_type
end

describe MasterData do
  context "in ActiveRecord" do
    it "should work with :update_attributes" do
      member = Person.new(:person_type => 'Person')
      member.update_attributes(:person_type => 'Cat')
      member.reload
      member.person_type.value.should=='Cat'      
    end    
    
    it "should work with :reload" do
      member = Person.new(:person_type => 'Person')
      member.person_type = 'Cat'
      member.save
      member.reload
      member.person_type.value.should=='Cat'      
    end
  end
end
