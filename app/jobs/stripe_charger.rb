class StripeCharger
	include Sidekiq::Worker
	def perform(guid)
		ActiveRecord::Base.connection_pool.with_connection do
			sale = Sale.find_by(guid: guid)
			puts "***** worker process *****"
			return unless sale
			sale.process!

		end 
	end
end