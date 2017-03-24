class SubscriptionsController < ApplicationController
  protect_from_forgery with: :exception
  before_action :load_subscription
  before_action :authenticate_authuser!, only: [:show, :edit, :update, :destroy,:index]
  def index
    @subscription = Subscription.all
  end

  def show
  end

  def new
    @subscription = Subscription.new
    @plan = Plan.find_by(name: 'elucidaid-premium-plan')
  end

  #braintree client token
  def clientToken
    @token = Braintree::ClientToken.generate
  end

  def create
      plan = @plan
      stipe_token = params[:stripeToken]
      email = params[:email]
      fullname = params[:cardholdername]
      braintree_nonce = params[:braintree]
      deviceData = params[:myDeviceData]
      user = CreateUser.call(email,fullname)
    if braintree_nonce and stipe_token.nil?
     subscription = Subscription.new(
        plan: plan,
        user: user,
        braintree_id: braintree_nonce
        )
    else
      subscription = Subscription.new(
        plan: plan,
        user: user,
        stripe_id: stipe_token
        )
    end
    if subscription.save
      StripeSubscriberWorker.perform_async(subscription.guid)
      render json: { guid: subscription.guid }
    else
      errors = subscription.errors.full_messages
      render json: {error: errors.join(" ")}, status: 400
    end
  end

  def status
    subscription = Subscription.find_by!(guid: params[:guid])
    render json: { status: subscription.state }
  end

  def pickup
    @subscription = Subscription.find_by!(guid: params[:guid])
    @product = @subscription.plan.product

  end

  def download
    @subscription = Subscription.find_by!(guid: params[:guid])
    resp = HTTParty.get(@subscription.plan.product.file.url)
    filename = @subscription.plan.product.file.url
    send_data resp.body,
    :filename => File.basename(filename),
    :content_type => resp.headers['Content-Type']
  end

  protected

  def load_subscription
    @subscription = Subscription.all
  end

end