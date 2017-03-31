class Subscription < ApplicationRecord
	include AASM
	aasm column: 'state', whiny_transitions: false do
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
	validates :guid, uniqueness: { case_sensitive: false }
	validates :status, uniqueness: { scope: :user_id, message: "Active subscription already exists."}
	after_save :send_to_Parse_server
	
	private
	def populate_guid
		if new_record?
			while !valid? || self.guid.nil?
				self.guid = SecureRandom.random_number(1_000_000_000).to_s(36)
			end 
		end
	end

	def send_to_Parse_server
		if self.guid.present? and self.status.present?
			user = self.user
			MessageParseWorker.perform_async(user.email)
		end
	end



	def subscribe_customer
		user = self.user
		plan = self.plan
		begin
			new_sub = nil
			save!
			if self.stripe_id.present?
				if user.stripe_customer_id.present?
	        		#my user already has stripe customer number, update payment sourse on stripe
	        		customer = Stripe::Customer.retrieve(user.stripe_customer_id)
	        		customer.source = self.stripe_id
	        		customer.save
	        	elsif user.stripe_customer_id.blank?
					#my user is a new stripe customer, update my user with stripe customer id
	        		customer = Stripe::Customer.create(
	          		source: self.stripe_id,
	          		email: user.email,
	          		description: user.description
	        		)
	        		user.stripe_customer_id = customer.id
	        		user.save!
	        	end
	        		customer = Stripe::Customer.retrieve(user.stripe_customer_id)
	        		new_sub = customer.subscriptions.create(plan: plan.stripe_id)
	        		self.update(stripe_id: new_sub.id)
        	elsif self.braintree_id.present?
        		if user.braintree_id.blank? 
        			#my user is a new Braintree customer, update my user with braintree_id
	        		result = Braintree::Customer.create(
			          :payment_method_nonce => self.braintree_id,
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
					else
						p result.errors
					end
	        	elsif user.braintree_id.present?
	        		#my user already has braintree_id, just subscribe with the new payment method
	        		customer = Braintree::Customer.find(user.braintree_id)
	        		new_sub = Braintree::Subscription.create(
			          :payment_method_token => customer.default_payment_method.token,
			          :plan_id => 'elucidaid_premium'
			        )
	        		self.update(braintree_id: new_sub.subscription.id) #braintree returns results object with create
	        		StripeMailer.delay.braintree_new_subscription(self)
	        	end
        	end
        	self.update(status: 'Active',expires_on: Date.current+14.days)
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
