class SubscriptionsController < ApplicationController
  protect_from_forgery with: :exception
  before_action :load_subscription
  before_action :authenticate_authuser!, only: [:edit, :update, :destroy, :index]
  before_action :authenticate_licenseuser!, only: [:show, :cancel]
  def index
    @subscription = Subscription.all
  end

  def show
    customer = User.find_by!(email: current_licenseuser.email)
    @subscriptions = customer.subscriptions
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
    plan = Plan.find_by(name: 'elucidaid-premium-plan')
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

  #TODO: improve link and file name
  def download
    @subscription = Subscription.find_by!(guid: params[:guid])
    resp = HTTParty.get(@subscription.plan.product.file.url)
    filename = @subscription.plan.product.file.url
    send_data resp.body,
    :filename => File.basename(filename),
    :content_type => resp.headers['Content-Type']
  end

  def cancel
   customer = User.find_by!(email: current_licenseuser.email)
   subscription = customer.subscriptions.find_by(guid: params[:guid])
   if subscription.present?
    begin
      if subscription.braintree_id.present?
        result = Braintree::Subscription.cancel(subscription.braintree_id)
      end
      if subscription.stripe_id.present?
        stripe_sub = Stripe::Subscription.retrieve(subscription.stripe_id)
        stripe_sub.delete
      end
      flash.now[:notice] = "Subscription successfully cancelled."
    rescue Stripe::StripeError, Braintree::NotFoundError => e
      flash.now[:alert] = "Request not processed. Please try again."
    end
    subscription.update(status: 'Cancelled')
  else
    flash.now[:alert] = "Cannot process request."
  end
end

protected

def load_subscription
  @subscription = Subscription.all
end

end