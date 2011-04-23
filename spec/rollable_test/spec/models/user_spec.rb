require 'spec_helper'

describe User do
  context "Rollable helpers" do
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
end
