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
			stripe_sub = nil
			save!
			if user.stripe_customer_id.blank?
        		customer = Stripe::Customer.create(
          		source: source,
          		email: user.email,
          		plan: plan.stripe_id,
          		description: user.description
        		)
        		user.stripe_customer_id = customer.id
        		user.save!
        		stripe_sub = customer.subscriptions.first
      		else
        		customer = Stripe::Customer.retrieve(user.stripe_customer_id)
        		stripe_sub = customer.subscriptions.create(plan: plan.stripe_id)
        	end
        	self.update(stripe_id: stripe_sub.id)
        	self.finish!
		rescue Stripe::StripeError => e
			puts e.message
			self.update_attributes(error: e.message)
			self.fail!
		end
	end
end
