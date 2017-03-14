class StripeSubscriberWorker
  include Sidekiq::Worker

  def perform(guid)
		ActiveRecord::Base.connection_pool.with_connection do
			subscription = Subscription.find_by(guid: guid)
			return unless subscription
			subscription.process!
		end 
	end
end