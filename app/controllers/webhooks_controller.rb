class WebhooksController < ApplicationController
	protect_from_forgery :except => :parse


	def parse
		webhook_notification = Braintree::WebhookNotification.parse(
		    request.params["bt_signature"],
		    request.params["bt_payload"]
		  )
		puts "********* [BRAINTREE Webhook Received. Kind: #{webhook_notification.kind} ] *********'
		if webhook_notification.subscription
			subscription = Subscription.find_by!(braintree_id: webhook_notification.subscription.id)
		end

		  if webhook_notification.kind == 'subscription_went_past_due'
		  elsif webhook_notification.kind == 'DisputeOpened'
		  	StripeMailer.delay.admin_dispute_created(webhook_notification.dispute)
		  elsif webhook_notification.kind == 'SubscriptionCanceled'
		  	subscription.update(status: 'canceled')
		  elsif webhook_notification.kind == 'SubscriptionChargedSuccessfully'
		  	subscription.update(status: 'charged')
		  	StripeMailer.delay.admin_paypalcharge_succeeded(webhook_notification.subscription)
		  elsif webhook_notification.kind == 'SubscriptionExpired'
		  	subscription.update(status: 'expired')
		  elsif webhook_notification.kind == 'SubscriptionTrialEnded'
		  elsif webhook_notification.kind == 'SubscriptionWentActive'
		  	subscription.finish
		  	subscription.update(status: 'active')
		  elsif webhook_notification.kind == 'SubscriptionWentPastDue'
		  	subscription.update(status: 'past_due')
		  end
		  	
		  render json: { status: 200 }
		  return 200
	end
end
