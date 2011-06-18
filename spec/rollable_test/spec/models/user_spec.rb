require 'spec_helper'

describe User do
  context "Rollable helpers" do
    it "should respond to setters" do
      @user = User.create
      @user.should respond_to(:is_owner)
      @user.should respond_to(:is_rider)
    end

    it "should have working setters" do
      @user = User.create
      @horse = Horse.create
      @user.is_owner(@horse)
      @user.is_owner_of?(@horse).should be_true
    end

    it "should respond to helper methods" do
      @user = User.new
      @user.should respond_to(:is_owner_of?)
      @user.should respond_to(:is_rider_on?)
    end

    it "should be able to get roles" do
      @user = User.create
      @user.roles.create(:rollable => Horse.create, :name => User.role_names.first )
      @user.roles.count.should == 1
    end

    it "should be able to use helpers" do
      @user = User.create
      @user.roles.create(:name => "owner", :rollable => Horse.create)
      @user.is_owner_of?(Horse.first).should be_true
    end
  end

  context "Bugs" do
    it "should still respond to is_a?" do
      @user = User.create
      @user.is_a?(User).should be_true
    end
  end
end
