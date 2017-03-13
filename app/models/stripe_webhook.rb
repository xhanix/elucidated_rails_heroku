class StripeWebhook < ApplicationRecord
	validates_uniqueness_of :stripe_id
end
