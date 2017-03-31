require 'rails_helper'
require 'stripe_mock'


RSpec.describe Subscription, type: :model do
	let(:stripe_helper) { StripeMock.create_test_helper }
	let (:stripe_plan) {stripe_helper.create_plan}
	let! (:stripe_user) {FactoryGirl.create(:user)}
	let (:stripe_subscription) {FactoryGirl.create(:subscription)}

	before { StripeMock.start }
	after { StripeMock.stop }

	it "has a valid factory" do
  		expect(FactoryGirl.create(:subscription)).to be_valid
  		expect(FactoryGirl.create(:subscription)).to have_state(:pending)
  	end

	it { is_expected.to validate_uniqueness_of(:guid).case_insensitive }
	
	it "does not allow duplicate active subscription per contact" do
     user = FactoryGirl.create(:user)
     subA =  FactoryGirl.create(:subscription,user: user, status: "active")
     subscription = FactoryGirl.build(:subscription, user: user, status: "active")
     subscription.valid?
     expect(subscription.errors[:status]).to include('Active subscription already exists.')
    end

    describe "after_save when stripe customer is new" do
    	before (:each) do
	    	plan = FactoryGirl.build(:plan, stripe_id: stripe_plan.id)
		   	@subscription = FactoryGirl.create(:subscription)
		   	@subscription.stripe_id = stripe_helper.generate_card_token
		   	@subscription.user = stripe_user
		   	@subscription.plan = plan
		   	@subscription.state = 'processing'
	        @subscription.send(:subscribe_customer)
    	end

	   it "sets stripe_customer_id field" do
	    expect(stripe_user.stripe_customer_id).not_to eq('')
	  end

	  it "subscribes customer on Stripe" do
	  	customer = Stripe::Customer.retrieve(stripe_user.stripe_customer_id)
	    expect(customer.subscriptions.count).to eq(1)
	  end

	  it "updates status to 'Active'" do
	  	expect(@subscription.status).to eq('Active')
	  end
	  it "updates expires_on field to two weeks from today" do
	  	expect(@subscription.expires_on).to eq(Date.current+14.days)
	  end
	  it "updates state field to finish" do
	  	expect(@subscription.state).to eq('finished')
	  end
	end
	describe "after_save when user already a stripe customer" do
    	before (:each) do
	    	plan = FactoryGirl.build(:plan, stripe_id: stripe_plan.id)
		   	@subscription = FactoryGirl.create(:subscription)
		   	@subscription.stripe_id = stripe_helper.generate_card_token
		   	was_a_customer = customer = Stripe::Customer.create({
											      email: 'johnny@appleseed.com',
											      source: stripe_helper.generate_card_token
											    })
		   	stripe_user.stripe_customer_id = was_a_customer.id
		   	@subscription.user = stripe_user
		   	@subscription.plan = plan
		   	@subscription.state = 'processing'
	        @subscription.send(:subscribe_customer)
    	end
	  it "subscribes customer on Stripe" do
	  	customer = Stripe::Customer.retrieve(stripe_user.stripe_customer_id)
	    expect(customer.subscriptions.count).to eq(1)
	  end
	  it "updates status to 'Active'" do
	  	expect(@subscription.status).to eq('Active')
	  end
	  it "updates expires_on field to two weeks from today" do
	  	expect(@subscription.expires_on).to eq(Date.current+14.days)
	  end
	  it "updates state field to finish" do
	  	expect(@subscription.state).to eq('finished')
	  end
	end
end

