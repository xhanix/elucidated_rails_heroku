require 'rails_helper'

RSpec.describe User, type: :model do
  it "has a valid factory" do
  	expect(FactoryGirl.create(:user)).to be_valid
  end
  it "is invalid without a fullname" do
  	expect(FactoryGirl.build(:user, fullname: nil)).not_to be_valid
  end
  it "is invalid without a email" do
  	expect(FactoryGirl.build(:user, email: nil)).not_to be_valid
  end
  
end
