require 'rails_helper'
require 'stripe_mock'
Devise::Test::ControllerHelpers

RSpec.describe SubscriptionsController, type: :controller do
	let(:stripe_helper) { StripeMock.create_test_helper }
	before do 
     Stripe.api_key = 'blablabla'
     StripeMock.start
    end
	after{StripeMock.stop}
	describe 'anonymous user' do
		it "GET #new assigns plans" do
			get :new
			expect(assigns(:plan)).to be_a(Plan)
	    end
		it "GET #show redirects to license user login page" do
			get :show, params: { id: 1 }
			expect(response).to redirect_to(new_licenseuser_session_url)
		end
		it "GET #cancel redirects to license user login page" do
			get :cancel, params: { id: 1 } 
			expect(response).to redirect_to(new_licenseuser_session_url)
		end
		it "GET #edit redirects to auth user login page" do
			get :edit, params: { id: 1 }
			expect(response).to redirect_to(new_authuser_session_url)
		end
		it "GET #index redirects to auth user login page" do
			get :index
			expect(response).to redirect_to(new_authuser_session_url)
		end
		it "GET #status renders AASM transition states" do
			subscription = FactoryGirl.create(:subscription)
			get :status, params: {guid: subscription.guid }
			@expected = { 
			        :status  => 'pending',
			}.to_json
			expect(response.body).to eq(@expected)
		end
		it "GET #pickup renders pickup template" do
			subscription = FactoryGirl.create(:subscription)
			get :pickup, params: {guid: subscription.guid }
			expect(response).to render_template(:pickup)
		end
		it "GET #app_download/:guid" do
			@subscription = FactoryGirl.create(:subscription)
			plan = FactoryGirl.create(:plan)
			plan.update(product: Product.find(233))
			@subscription.update(plan: plan)
			stub_request(:any, /system/)
			stub_request(:get, "*")
			get :download, params: {guid: @subscription.guid }
			expect(response.status).to eq(200)
			expect(response.header['Content-Type']).to eq('application/octet-stream')
		end

		it "POST #create send job to StripeSubscriberWorker" do
			expect {
				post :create, :params => {email: User.last.email, cardholdername: User.last.fullname, stripeToken: '123'}
			}.to change(StripeSubscriberWorker.jobs, :size).by(1)
		end
	end

	describe 'auth user' do
		login_authuser
		it "GET #index renders index" do
			get :index
			assigns(:subscriptions)
			expect( response ).to render_template( :index )
			expect(response).not_to redirect_to(new_authuser_session_url)
		end
	end

	describe 'license user' do
		login_licenseuser
		before { 
			@subscription = FactoryGirl.create(:subscription)
			@user = FactoryGirl.create(:user, email: subject.current_licenseuser.email)
			@subscription.update(user: @user)
			plan = stripe_helper.create_plan(:id => 'my_plan', :amount => 1500)
			@customer = Stripe::Customer.create(
          		source: stripe_helper.generate_card_token,
          		email: @user.email,
          		description: @user.description
        		)
			@new_sub = @customer.subscriptions.create(plan: plan.id)
			@subscription.update(stripe_id: @new_sub.id)
			@user.update(stripe_customer_id: @customer.id)
		}
		it "GET #show renders show subscriptions" do
			get :show, params: {id: 1}
			expect(assigns(:subscriptions).first.id).not_to eq(1)
			expect( response ).to render_template( :show, params: {id: 1} )
			expect(response).not_to redirect_to(new_authuser_session_url)
		end

		it "GET #cancel deletes customer subscription on Stripe server" do
			stripeCustomer = Stripe::Customer.retrieve(@user.stripe_customer_id)
			expect {
				get :cancel, params: { id:@subscription.id,guid: @subscription.guid }
				stripeCustomer = Stripe::Customer.retrieve(@user.stripe_customer_id)
			}.to change{stripeCustomer.subscriptions.total_count}.by(-1)
		end
		it "GET #cancel sets subscription status to Cancelled" do
			status = @subscription.status
			expect {
				get :cancel, params: { id:@subscription.id,guid: @subscription.guid }
				@subscription.reload
				status = @subscription.status
			}.to change{status}.to('Cancelled')
		end
	end


end
