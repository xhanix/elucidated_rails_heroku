require 'rails_helper'

RSpec.describe Subscription, type: :model do	
	it "has a valid factory" do
  		expect(FactoryGirl.create(:subscription)).to be_valid
  	end

	it { is_expected.to validate_uniqueness_of(:guid).case_insensitive }
	
end

