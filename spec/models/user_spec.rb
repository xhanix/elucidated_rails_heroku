require 'rails_helper'

RSpec.describe User, type: :model do
  
  it "has a valid factory" do
  	expect(FactoryGirl.create(:user)).to be_valid
  end

  it "is invalid without a fullname" do
  	user = FactoryGirl.build(:user, fullname: nil)
  	user.valid?
  	expect(user.errors[:fullname]).to include("can't be blank")
  end
  
  it "is invalid without a email" do
  	expect(FactoryGirl.build(:user, email: nil)).not_to be_valid
  end

  it "is invalid with a duplicate email address" do
    userA = FactoryGirl.create(:user)
    user = FactoryGirl.build(:user,email: userA.email)
    user.valid?
    expect(user.errors[:email]).to include("has already been taken")
 end
  
end
