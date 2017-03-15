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
		StripeMailer.receipt(charge).deliver
		StripeMailer.admin_charge_succeeded(charge).deliver
	end

  events.subscribe('invoice.payment_succeeded') do |event|
    invoice = event.data.object
    user = User.find_by(stripe_id: invoice.customer)
    invoice_sub = invoice.lines.data.select { |i| i.type == 'subscription' }.first.id
    subscription = Subscription.find_by(stripe_id: invoice_sub)

    charge = invoice.charge

    balance_txn = Stripe::BalanceTransaction.retrieve(charge.balance_transaction)

    InvoicePayment.create(
      stripe_id: invoice.id,
      amount: invoice.total,
      fee_amount: balance_txn.fee,
      user_id: user.id,
      subscription_id: subscription.id
    )
  end
end