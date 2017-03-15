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
    @plan = Plan.find(params[:plan_id])
  end

  def create
    plan = Plan.find(params[:plan_id])
    token = params[:stripeToken]
    email = params[:email]
    fullname = params[:name]
    @key = SecureRandom.hex(12)
    user = CreateUser.call(email,@key,fullname)
    subscription = Subscription.new(
      plan: plan,
      user: user,
      stripe_id: token
    )
    if subscription.save
      StripeSubscriberWorker.perform_async(subscription.guid)
      render json: { guid: subscription.guid }
    else
      errors = subscription.errors.full_messages
      render json: {error: errors.join(" ")}, status: 400
    end
    flash[:key] = @key
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