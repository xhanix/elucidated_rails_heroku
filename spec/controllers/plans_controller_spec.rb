require 'stripe_mock'
require 'rails_helper'

Devise::Test::ControllerHelpers


RSpec.describe PlansController, type: :controller do
	WebMock.allow_net_connect!
	let(:product) {FactoryGirl.create(:product)}
	let(:plan) {FactoryGirl.create(:plan,:amount=>111, :interval=>'year', :description=>'test', :product_id=>product.id, :trial_period_days=>'7')}
	let(:stripe_helper) { StripeMock.create_test_helper }
	before do 
     Stripe.api_key = 'blablabla'
     StripeMock.start
    end
	after{StripeMock.stop}

	describe 'anonymous user' do
		it "GET #new redirects to auth user login page" do
			get :new
			expect(response).to redirect_to(new_authuser_session_url)
		end

		it "POST #create does not create" do
			product = FactoryGirl.create(:product)
			plan_params = FactoryGirl.attributes_for(:plan,:amount=> 111 , :interval=>'year', :description=>'test', :product_id=>product.id, :trial_period_days=>'7')
  			expect { post :create, params:{:plan => plan_params }}.not_to change(Plan, :count)
		end

		it "POST #create redirects to auth user login page" do
			post :create
			expect(response).to redirect_to(new_authuser_session_url)
		end


		it "GET #edit redirects to auth user login page" do
			@plan = FactoryGirl.create(:plan)
			get :edit, params: { id: @plan.id }
			expect(response).to redirect_to(new_authuser_session_url)
		end

		it "PATCH #update redirects to auth user login page" do
			@plan = FactoryGirl.create(:plan)
			patch :update, params: { id: @plan.id }
			expect(response).to redirect_to(new_authuser_session_url)
		end

		describe 'DELETE destroy' do
		  before :each do
		    @plan = FactoryGirl.create(:plan,:amount=>111, :interval=>'year', :description=>'test', :product_id=> product.id, :trial_period_days=>'7')
		  end
		  
		  it "does not delete the plan" do
		    expect{delete :destroy, params: {id: @plan}}.to change(Plan,:count).by(0)
		  end
		    
		  it "redirects to plans#index" do
		    delete :destroy, params: {id: plan}
		    expect(response).to redirect_to(new_authuser_session_url)
		  end
		end
	end

	describe 'auth user' do
	      login_authuser	
	      
	    it "GET #new redirects to auth user login page" do
			get :new
			assigns(:plans)
			expect(response).not_to redirect_to(new_authuser_session_url)
		end

		it "GET #index renders index template" do
			get :index
			expect( response ).to render_template( :index )
		end
	
		it "POST #create increases Plan count" do
			plan_params = FactoryGirl.attributes_for(:plan, :amount=>111, :interval=>'year', :description=>'test', :product_id=>product.id, :trial_period_days=>'7')
  			expect { post :create, params:{:plan => plan_params }}.to change(Plan, :count).by(1)
  			expect(response).to redirect_to(plan_url(Plan.last.id))
  			expect(Stripe::Plan.retrieve(Plan.last.stripe_id).trial_period_days).to eq(7)
		end

		it "GET #edit renders edit template" do
			get :edit, params: { id: plan.id }
			expect( response ).to render_template( :edit )
		end
		

		it "PATCH #update updates plan product_id" do
			 attr = {:product_id => product.id}
			    put :update, params: {:id => plan.id, :plan => attr}
			    plan.reload
			    expect(response).to redirect_to(plan)
			    expect(plan.product_id).to eql attr[:product_id]
		end
			it "PATCH #update with non-existing product" do
			 product = FactoryGirl.create(:product)
			 attr = {:product_id => '1234567890000001234567890'}
			    put :update, params: {:id => plan.id, :plan => attr}
			    expect(response.status).to eql(422)
		end
	
		  it "DELETE #destroy the plan" do
		    stripe_plan = stripe_helper.create_plan(:id => Faker::Number.number(12), :amount => 1500)
		    plan = FactoryGirl.create(:plan,:amount=>111,stripe_id: stripe_plan.id, :interval=>'year', :description=>'test', :product_id=> product.id, :trial_period_days=>'7')
		    expect{delete :destroy, params: {:id=>plan.id}}.to change(Plan,:count).by(-1)
		    expect(response).to redirect_to(plans_url)
		  end		
	end
end
