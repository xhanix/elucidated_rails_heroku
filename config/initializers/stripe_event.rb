StripeEvent.event_retriever = lambda do |params|
	return nil if StripeWebhook.exists?(stripe_id: params[:id])
	StripeWebhook.create!(stripe_id: params[:id])
	Stripe::Event.retrieve(params[:id])
end


StripeEvent.configure do |events|

	events.subscribe 'charge.dispute.created' do |event|
		StripeMailer.admin_dispute_created(event.data.object).deliver
	end 
  
	events.subscribe 'charge.succeeded' do |event|
		charge = event.data.object
	end

  events.subscribe('invoice.payment_succeeded') do |event|
    invoice = event.data.object
    user = User.find_by(stripe_customer_id: invoice.customer)
    invoice_sub = invoice.lines.data.select { |i| i.type == 'subscription' }.first.id
    subscription = Subscription.find_by(stripe_id: invoice_sub)
    charge = Stripe::Charge.retrieve(invoice.charge)
    balance_txn = Stripe::BalanceTransaction.retrieve(charge.balance_transaction)
    card =  invoice.customer.sources.retrieve(charge.sources.id)
    InvoicePayment.create(
      stripe_id: invoice.id,
      amount: invoice.total,
      fee_amount: balance_txn.fee,
      user_id: user.id,
      subscription_id: subscription.id
    )
    StripeMailer.delay.receipt(invoice,card)
    StripeMailer.delay.admin_invoice_succeeded(invoice)
  end
end