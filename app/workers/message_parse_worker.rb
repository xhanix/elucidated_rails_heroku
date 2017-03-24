# send a message to parse to create a new user
#### TODO: need user data to be send on RabbitMQ
class MessageParseWorker
  include Sidekiq::Worker

  def perform(email)
		ActiveRecord::Base.connection_pool.with_connection do
			user = User.find_by(email: email)
			user.subscriptions.where(plan_id: 1).first
			subscriptionStatus = User.last.subscriptions.where(plan_id: 1).first.status
			return unless user
			Publisher.publish({username: user.fullname, email: user.email, description: user.description, licenseState: subscriptionStatus})
		end 
	end
end