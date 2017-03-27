class WebhooksTest < ActionDispatch::IntegrationTest
  test 'invoice created' do
    event = StripeMock.mock_webhook_event('invoice.created', id: 'test_evt_1')
    #product = Product.create(price: 100, name: 'foo')
    #sale = Sale.create(stripe_id: 'abc123', amount: 100, email: 'foo@bar.com', product: product)
    post '/stripe-events', params: {id: event.id}
    assert_equal "200", response.code
    #assert_equal 2, StripeMailer.deliveries.length
    assert_equal 'test_evt_1', StripeWebhook.last.stripe_id
  end
end