Rails.configuration.stripe = {
  publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'],
  secret_key:      ENV['STRIPE_SECRET_KEY'],
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]


Braintree::Configuration.environment = :sandbox
Braintree::Configuration.merchant_id = ENV['BRAINTREE_MERCHANT']
Braintree::Configuration.public_key = ENV['BRAINTREE_PUBLIC']
Braintree::Configuration.private_key = ENV['BRAINTREE_PRIVATE']