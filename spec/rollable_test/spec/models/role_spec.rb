require 'spec_helper'

describe Role do
  context "Rollable" do
    it "should validate inclusion of roll names" do
      role = Role.new
      role.should_not be_valid
      role.user = User.create
      role.should_not be_valid
      role.rollable = Horse.create
      role.should_not be_valid
      role.name = User.role_names.first
      role.should be_valid
    end

    it "should validate inclusion of rollable types" do
      u = User.create
      r = u.roles.create(:name => "owner" )
      r.should be_valid
      r.rollable = u
      r.should_not be_valid
      r.rollable = Horse.create
      r.should be_valid
    end
  end
end
