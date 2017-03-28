require 'rails_helper'
Devise::Test::ControllerHelpers

RSpec.describe SubscriptionsController, type: :controller do
	

	
	describe 'GET #new' do
		let(:plan) { FactoryGirl.create(:plan) }
		
		it "assigns @plan" do
	      p plan
	      get :new
	      expect(assigns(:plans)).to eq([plan])
	    end
	end
	describe 'GET #show' do
		before { get :show, params: { id: 1 } }
		it { should redirect_to(new_licenseuser_session_url) }
	end

	describe 'GET #index' do
		before { get :index}
		it { should redirect_to(new_authuser_session_url) }
	end


	describe 'POST #create' do
		it "sends job to background subscriber worker" do
			user = FactoryGirl.attributes_for(:user)
			subscription = FactoryGirl.create(:subscription)
			#post :create, :params => {email: user[:email], cardholdername: user[:fullname], stripeToken: '123'}
			#expect(StripeSubscriberWorker).to have_enqueued_job('Perform')
			StripeSubscriberWorker.perform_async('123')
			#assert_equal 1, StripeSubscriberWorker.jobs.size
			StripeSubscriberWorker.drain
		end
	end




end
