StripeEvent.event_retriever = lambda do |params|
	return nil if StripeWebhook.exists?(stripe_id: params[:id])
	StripeWebhook.create!(stripe_id: params[:id])
	Stripe::Event.retrieve(params[:id])
end


StripeEvent.configure do |events|
	events.subscribe 'charge.dispute.created' do |event|
		StripeMailer.delay.admin_dispute_created(event.data.object)
	end 
	events.subscribe 'charge.succeeded' do |event|
		charge = event.data.object
    StripeMailer.delay.admin_charge_succeeded(charge)
	end
  events.subscribe('invoice.created') do |event|
    # Occurs whenever a new invoice is created.
    invoice = event.data.object
    if invoice.total == 0
        #Invoice is for free trial
      invoice_sub = invoice.lines.data.select { |i| i.type == 'subscription' }.first.id
      subscription = Subscription.find_by(stripe_id: invoice_sub)
      StripeMailer.delay.invoice(invoice,subscription)
      StripeMailer.delay.admin_invoice_succeeded(invoice)
    end
  end
  events.subscribe('invoice.payment_succeeded') do |event|
    # Occurs whenever an invoice attempts to be paid, and the payment succeeds. $0 total and no charge object for Free Trial.
    invoice = event.data.object
    if invoice.total > 0
      # invoice is not for free trial
      user = User.find_by(stripe_customer_id: invoice.customer)
      invoice_sub = invoice.lines.data.select { |i| i.type == 'subscription' }.first.id
      subscription = Subscription.find_by(stripe_id: invoice_sub)
      charge = Stripe::Charge.retrieve(invoice.charge)
      balance_txn = Stripe::BalanceTransaction.retrieve(charge.balance_transaction)
      card_brand =  charge.source.brand
      card_last4 = charge.source.last4
      InvoicePayment.create(
        stripe_id: invoice.id,
        amount: invoice.total,
        fee_amount: balance_txn.fee,
        user_id: user.id,
        subscription_id: subscription.id
      )
      StripeMailer.delay.receipt(invoice,card_brand,card_last4)
      user.update(card_expiration: Date.new(charge.source.exp_year, charge.source.exp_month, 1))
      subscription.update(payment_status: 'paid', expires_on: Date.current+1.year )
    end
  end
  events.subscribe('invoice.payment_failed') do |event|
    invoice = event.data.object
    user = User.find_by(stripe_customer_id: invoice.customer)
    invoice_sub = invoice.lines.data.select { |i| i.type == 'subscription' }.first.id
    subscription = Subscription.find_by(stripe_id: invoice_sub)
    subscription.update(payment_status: 'failed')
    StripeMailer.delay.payment_failed(invoice)
  end
  events.subscribe('customer.subscription.trial_will_end') do |event|
    #Occurs three days before the trial period of a subscription is scheduled to end.
    subscription = event.data.object
    StripeMailer.delay.trial_end_reminder(subscription)
  end


end