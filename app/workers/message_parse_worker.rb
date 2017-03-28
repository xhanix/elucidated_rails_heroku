# send a message to parse to create a new user
#### TODO: need user data to be send on RabbitMQ
class MessageParseWorker
  include Sidekiq::Worker

  def perform(email)
		ActiveRecord::Base.connection_pool.with_connection do
			user = User.find_by(email: email)
			#subscription = user.subscriptions.find_by(guid: guid)
			sub_status = 'Active' # use instead of subscription.status to leave Parse account active for now
			return unless subscription
			Publisher.publish({username: user.fullname, email: user.email, description: user.description, licenseState: sub_status})
		end 
	end
end