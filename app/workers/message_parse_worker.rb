# send a message to parse to create a new user
#### TODO: need user data to be send on RabbitMQ
class MessageParseWorker
  include Sidekiq::Worker

  def perform(email,guid)
		ActiveRecord::Base.connection_pool.with_connection do
			user = User.find_by(email: email)
			subscriptionStatus = Subscriptions.find_by!(guid: guid).status
			return unless user
			Publisher.publish({username: user.fullname, email: user.email, description: user.description, licenseState: subscriptionStatus})
		end 
	end
end