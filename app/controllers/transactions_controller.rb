class TransactionsController < ApplicationController
	before_filter :strip_iframe_protection
  	before_action :authenticate_authuser!, only: [:index]
	def iframe
		@product = Product.find_by!(permalink: params[:permalink])
		@sale = Sale.new(product_id: @product)
	end

	def new
		@product = Product.find_by!(
			permalink: params[:permalink]
			)
		token = params[:stripeToken]
	end

	def pickup
		@sale = Sale.find_by!(guid: params[:guid])
		@product = @sale.product
	end

	def create
		product = Product.find_by!(
			permalink: params[:permalink]
			)
		token = params[:stripeToken]
		sale = Sale.new
		sale.amount = 14999
		sale.product_id = product.id
		sale.stripe_token = token
		sale.email = params[:email]
		if sale.save
			StripeChargerWorker.perform_async(sale.guid)
			render json: { guid: sale.guid }
		else
			errors = sale.errors.full_messages
			render json: {error: errors.join(" ")}, status: 400
		end
	end

	def status
		sale = Sale.find_by!(guid: params[:guid])
		render json: { status: sale.state }
	end


	def download
		@sale = Sale.find_by!(guid: params[:guid])
		resp = HTTParty.get(@sale.product.file.url)
		filename = @sale.product.file.url
		send_data resp.body,
		:filename => File.basename(filename),
		:content_type => resp.headers['Content-Type']
	end

	private
	def strip_iframe_protection
		response.headers.delete('X-Frame-Options')
	end

end