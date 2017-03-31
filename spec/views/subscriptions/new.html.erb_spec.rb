require 'stripe_mock'
require 'rails_helper'

RSpec.describe "subscriptions/new", type: :view do

	it "displays the payment form" do
	 assign(:subscription, Subscription.new)
     assign(:plan, FactoryGirl.create(:plan))
     render
     expect(rendered).to have_field("cardholdername")
     expect(rendered).to have_field("email")
  end
 
end
