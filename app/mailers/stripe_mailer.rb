class StripeMailer < ActionMailer::Base
	default from: 'help@elucidaid.com'
	def admin_dispute_created(charge)
		@charge = charge
		@sale = Sale.find_by(stripe_id: @charge.id)
		if @sale
			mail(to: 'hani@aiderbotics.com', subject: "Dispute created on charge #{@sale.guid} (#{charge.id})").deliver
		end 
	end

	def admin_invoice_succeeded(invoice)
		@invoice = invoice
		@user = User.find_by(stripe_customer_id: invoice.customer)
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
		mail(to: @sale.email, subject: "Your eLucidaid Purchase Receipt")
	end
	
end