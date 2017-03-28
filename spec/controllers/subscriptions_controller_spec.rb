require 'rails_helper'

RSpec.describe SubscriptionsController, type: :controller do
	

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
		it "sends job to background Parse messenger worker" do
			#user = FactoryGirl.attributes_for(:user)
			Sidekiq::Worker.clear_all
			FactoryGirl.create(:subscription)
			expect {
				MessageParseWorker.perform_async(1)
			}.to change(MessageParseWorker.jobs, :size).by(1)
			MessageParseWorker.drain
            assert_equal 0, MessageParseWorker.jobs.size
		end


	end




end
