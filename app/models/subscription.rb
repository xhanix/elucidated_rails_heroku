class Subscription < ApplicationRecord
	include AASM
	aasm column: 'state' do
		state :pending, initial: true
		state :processing
		state :finished
		state :errored
		event :process, after: :subscribe_customer do
			transitions from: :pending, to: :processing
		end
		event :finish do
			transitions from: :processing, to: :finished
		end
		event :fail do
			transitions from: :processing, to: :errored
		end
	end

	belongs_to :user
	belongs_to :plan
	has_paper_trail
	before_save :populate_guid
	validates_uniqueness_of :guid
	
	private
	def populate_guid
		if new_record?
			while !valid? || self.guid.nil?
				self.guid = SecureRandom.random_number(1_000_000_000).to_s(36)
			end 
		end 
	end



	def subscribe_customer
		user = self.user
		plan = self.plan
		source = self.stripe_id
		begin
			new_sub = nil
			save!
			if user.stripe_customer_id.blank? and self.stripe_id.present?
        		customer = Stripe::Customer.create(
          		source: source,
          		email: user.email,
          		plan: plan.stripe_id,
          		description: user.description
        		)
        		user.stripe_customer_id = customer.id
        		user.save!
        		new_sub = customer.subscriptions.first
        		sub_provider = "Stripe"
        	elsif user.stripe_customer_id.present?
        		customer = Stripe::Customer.retrieve(user.stripe_customer_id)
        		new_sub = customer.subscriptions.create(plan: plan.stripe_id)
        		sub_provider = "Stripe"
        	elsif user.braintree_id.blank? and self.braintree_id.present?
        		result = Braintree::Customer.create(
		          :payment_method_nonce => source,
		          :email => user.email,
		          :first_name => user.fullname,
		          )
        		if result.success?
					new_sub = Braintree::Subscription.create(
						:payment_method_token => result.customer.default_payment_method.token,
				        :plan_id => 'elucidaid_premium'
			        )
	        		user.braintree_id = result.customer.id
	        		user.save!
	        		sub_provider = "Braintree"
				else
					p result.errors
				end
        	elsif user.braintree_id.present?
        		customer = Braintree::Customer.find(user.braintree_id)
        		new_sub = Braintree::Subscription.create(
		          :payment_method_token => customer.default_payment_method.token,
		          :plan_id => 'elucidaid_premium'
		        )
		        sub_provider = "Braintree"
        	end
        	if sub_provider == "Stripe"
        		self.update(stripe_id: new_sub.id)
        	else
        		self.update(braintree_id: new_sub.subscription.id) #braintree returns results object with create
        		StripeMailer.delay.braintree_receipt(self)
    			StripeMailer.delay.admin_paypalcharge_succeeded(self)
        	end
        	self.finish!
		rescue Stripe::StripeError, Braintree::NotFoundError, Braintree::AuthorizationError, 
			Braintree::DownForMaintenanceError, Braintree::ForgedQueryString, Braintree::NotFoundError, 
			Braintree::ServerError, Braintree::SSLCertificateError, Braintree::UnexpectedError, 
			Braintree::TooManyRequestsError => e
			puts e.message
			self.update_attributes(error: e.message)
			self.fail!
		end
	end
end
