require 'rails_helper'

RSpec.describe Plan, type: :model do
    it "has a valid factory" do
  		expect(FactoryGirl.create(:plan)).to be_valid
  	end
end
