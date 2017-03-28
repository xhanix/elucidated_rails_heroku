class StripeMailer < ActionMailer::Base
	default from: 'help@elucidaid.com'
	### emails for Stripe Events
	def admin_dispute_created(dispute)
		@dispute = dispute
		mail(to: 'hani@aiderbotics.com', subject: "Dispute opened")
	end

	def admin_charge_succeeded(charge)
		@charge = charge
		@user = User.find_by(stripe_customer_id: charge.customer)
		mail(to: 'hani@aiderbotics.com', subject: 'Woo! Charge Succeeded!')
	end

	def admin_invoice_succeeded(invoice)
		@invoice = invoice
		mail(to: 'hani@aiderbotics.com', subject: 'Woo! New Invoice and Download!')
	end

	def admin_subscription_cancelled(guid)
		@subscription = Subscription.find_by(guid: guid)
		@user = @subscription.user
		mail(to: 'hani@aiderbotics.com', subject: 'Subscription Cancellation Requested')
	end

	def payment_failed(invoice)
		#send mail reminding them to try paying again with link to payment page
	end

	def trial_will_end(subscription)
		#send reminder email for free trial ending in 3 days
	end

	def receipt(invoice,card_brand,card_last4)
		@invoice = invoice
		@card_brand = card_brand
		@card_last4 = card_last4
		@user = User.find_by(stripe_customer_id: invoice.customer)
		subscription = @user.subscriptions.last
		@download_link =  Rails.application.routes.url_helpers.app_download_url(subscription.guid,:host => 'elucidaid.com')
		@account_link = Rails.application.routes.url_helpers.subscription_url(subscription.id, :host => 'elucidaid.com')
		html = render_to_string('stripe_mailer/receipt.html')
		pdf = Docverter::Conversion.run do |c|
			c.from = 'html'
			c.to = 'pdf'
			c.content = html
		end
		attachments['Receipt.pdf'] = pdf
		mail(to: @user.email, subject: "Your eLucidaid Subscription Receipt")
	end

	def invoice(invoice,subscription)
		@invoice = invoice
		@user = User.find_by(stripe_customer_id: invoice.customer)
		@download_link =  Rails.application.routes.url_helpers.app_download_url(subscription.guid,:host => 'https://elucidaid.com')
		@account_link = Rails.application.routes.url_helpers.subscription_url(subscription.id, :host => 'elucidaid.com')
		mail(to: @user.email, subject: "Your eLucidaid License Key and Invoice")
	end

	#### emails for Braintree Events
	def braintree_new_subscription(subscription)
		@invoice = subscription
		@user = subscription.user
		@download_link =  Rails.application.routes.url_helpers.app_download_url(subscription.guid,:host => 'elucidaid.com')
		@account_link = Rails.application.routes.url_helpers.subscription_url(subscription.id, :host => 'elucidaid.com')
		mail(to: @user.email, subject: "Your eLucidaid License Key and Invoice")
	end

	def braintree_receipt(subscription)
		@local_record = Subscription.find_by!(braintree_id: subscription)
		@user = local_record.user
		if subscription.transactions.count > 0 and subscription.transactions.first.amount > 100
			@paid_on = subscription.transactions.first.created_at
			@download_link =  Rails.application.routes.url_helpers.app_download_url(@local_record.guid,:host => 'elucidaid.com')
			@account_link = Rails.application.routes.url_helpers.subscription_url(@local_record.id, :host => 'elucidaid.com')
			mail(to: @user.email, subject: "Your eLucidaid Subscription Receipt")
		end
	end
	
end