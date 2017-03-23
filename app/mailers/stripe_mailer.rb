class StripeMailer < ActionMailer::Base
	default from: 'help@elucidaid.com'
	def admin_dispute_created(dispute)
		@dispute = dispute
		mail(to: 'hani@aiderbotics.com', subject: "Dispute opened")
	end

	def admin_invoice_succeeded(invoice)
		@invoice = invoice
		@user = User.find_by(stripe_customer_id: invoice.customer)
		mail(to: 'hani@aiderbotics.com', subject: 'Woo! Charge Succeeded!')
	end

	def admin_paypalcharge_succeeded(subscription)
		@subscription = Subscription.find_by(braintree_id: subscription.id)
		mail(to: 'hani@aiderbotics.com', subject: 'Woo! Charge Succeeded!')
	end

	def receipt(invoice,card_brand,card_last4)
		@invoice = invoice
		@card_brand = card_brand
		@card_last4 = card_last4
		@user = User.find_by(stripe_customer_id: invoice.customer)
		html = render_to_string('stripe_mailer/receipt.html')
		pdf = Docverter::Conversion.run do |c|
			c.from = 'html'
			c.to = 'pdf'
			c.content = html
		end
		attachments['Invoice.pdf'] = pdf
		mail(to: @user.email, subject: "Your eLucidaid License Key and Invoice")
	end

	def braintree_receipt(subscription)
		@invoice = subscription
		@card_brand = 'PayPal'
		@card_last4 = ' '
		@user = subscription.user
		html = render_to_string('stripe_mailer/braintree_receipt.html')
		pdf = Docverter::Conversion.run do |c|
			c.from = 'html'
			c.to = 'pdf'
			c.content = html
		end
		attachments['Invoice.pdf'] = pdf
		mail(to: @user.email, subject: "Your eLucidaid License Key and Invoice")
	end

	
end