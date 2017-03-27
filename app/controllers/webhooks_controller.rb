class WebhooksController < ApplicationController
	protect_from_forgery :except => :parse


	def parse
		webhook_notification = Braintree::WebhookNotification.parse(
		    request.params["bt_signature"],
		    request.params["bt_payload"]
		  )
		puts "********* [BRAINTREE Webhook Received. Kind: #{webhook_notification.kind} ] *********"
		if webhook_notification.subscription
			subscription = Subscription.find_by(braintree_id: webhook_notification.subscription.id)
		  if webhook_notification.kind == 'subscription_went_past_due'
		  	#Don't do anything for now. SubscriptionChargedUnsuccessfully should send out reminder.
		  elsif webhook_notification.kind == 'DisputeOpened'
		  	StripeMailer.delay.admin_dispute_created(webhook_notification.dispute)
		  elsif webhook_notification.kind == 'SubscriptionCanceled'
		  	#subscription.update(status: 'cancelled')
		  	#Do manual handling. email is sent out to me from subscription controller cancel action
		  elsif webhook_notification.kind == 'SubscriptionChargedSuccessfully'
		  	subscription.update(payment_status: 'paid', expires_on: Date.current+1.year)
		  	StripeMailer.delay.braintree_receipt(webhook_notification.subscription)
		  	StripeMailer.delay.admin_paypalcharge_succeeded(webhook_notification.subscription)
		 # elsif webhook_notification.kind == 'SubscriptionExpired'
		 # 	subscription.update(status: 'expired')
		  elsif webhook_notification.kind == 'SubscriptionTrialEnded'
		  	#Don't do anything for now, the charging webhook should take care of things.
		  	#TODO: send email 3 days before trial ends.
		  elsif webhook_notification.kind == 'SubscriptionWentActive'
		  	subscription.finish
		  elsif webhook_notification.kind == 'SubscriptionChargedUnsuccessfully'
		  	#A subscription already exists and fails to create a successful charge. 
		  	subscription.update(payment_status: 'failed')

		  end
		end	
		  render json: { status: 200 }
		  return 200
	end
end
