require 'spec_helper'

describe Horse do
  context "Target helper methods" do
    it "should have the methods" do
      horse = Horse.create
      horse.should respond_to("has_rider?")
      horse.should respond_to("get_riders")
    end

    it "should respond correctly without roles" do
      horse = Horse.create
      horse.has_rider?.should eq(false)
      horse.get_riders.should eq([])
    end

    it "should return correct values if roles are set" do
      horse = Horse.create
      user = User.create
      user.roles.create(:rollable => horse, :name => "rider")
      horse.has_rider?.should eq(true)
      horse.get_riders.should include(user)
    end
  end
end
