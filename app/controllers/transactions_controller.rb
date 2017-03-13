class TransactionsController < ApplicationController
	before_filter :strip_iframe_protection
	def iframe
		@product = Product.find_by!(permalink: params[:permalink])
		@sale = Sale.new(product_id: @product)
	end

	def new
		@product = Product.find_by!(
			permalink: params[:permalink]
			)
		token = params[:stripeToken]
		puts "**** new transactions ***"
	end

	def pickup
		@sale = Sale.find_by!(guid: params[:guid])
		@product = @sale.product
	end

	def create
		product = Product.find_by!(
			permalink: params[:permalink]
			)
		
		sale = @product.sales.create(
			amount:       @product.price,
			email:        params[:email],
			stripe_token: params[:stripeToken]
			)

		sale.process!

		if sale.finished?
			redirect_to pickup_url(guid: sale.guid)
		else
			flash.now[:alert] = sale.error
			render :new
		end
	end

	def status
		sale = Sale.find_by!(guid: params[:guid])
		render json: { status: sale.state }
		puts sale.state
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