class SubscriptionsController < ApplicationController

  before_action :load_subscription

  def index
    @subscription = Plan.all
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
    user = CreateUser.call(email)
    subscription = Subscription.new(
      plan: plan,
      user: user,
      stripe_id: token
    )
    if subscription.save
      puts "********** TOKEN:"
      puts "********** TOKEN:"+subscription.stripe_id+"********************"
      puts "********** TOKEN:"
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
    @subscription = subscription.find_by!(guid: params[:guid])
    @product = @subscription.plan.product
  end

  def download
    @subscription = subscription.find_by!(guid: params[:guid])
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