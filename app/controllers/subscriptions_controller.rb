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
    @token = Braintree::ClientToken.generate
  end

  #braintree client token
  def clientToken
    @token = Braintree::ClientToken.generate
  end

  def create
      plan = Plan.last
      stipe_token = params[:stripeToken]
      email = params[:email]
      fullname = params[:cardholdername]
      braintree_nonce = params[:braintree]
      deviceData = params[:myDeviceData]
      @key = SecureRandom.hex(12)
      user = CreateUser.call(email,@key,fullname)
    if braintree_nonce and stipe_token.nil?
      if user.braintree_id?
        customer = Braintree::Customer.find(user.braintree_id)
      else
        result = Braintree::Customer.create(
          :payment_method_nonce => braintree_nonce,
          :email => email,
          :first_name => fullname,
          :custom_fields => {
            :license_key => @key
          }
          )
        if result.success?
          #puts result.customer.id
          #paypal_account = Braintree::PayPalAccount.find(result.customer.payment_methods[0].token)
          customer = result.customer
          user.update(braintree_id: customer.id)
        else
          p result.errors
        end
      end
      # can get user from here: subscription.status_history[0].user
        result = Braintree::Subscription.create(
          :payment_method_token => customer.default_payment_method.token,
          :plan_id => 'elucidaid_premium'
        )
        subscription = Subscription.new(
          plan: plan,
          user: user,
          braintree_id: result.subscription.id
        )
        flash[:key] = @key
        if subscription.save
          redirect_to "/download_app/" + subscription.guid
        end
    elsif !braintree_nonce and stipe_token
      subscription = Subscription.new(
        plan: plan,
        user: user,
        stripe_id: stipe_token
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