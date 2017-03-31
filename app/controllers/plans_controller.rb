class PlansController < ApplicationController
	before_action :set_plan, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_authuser!, only: [:show, :edit, :update, :destroy,:index,:create, :new]
	def index
		@plans = Plan.all
	end

	def show
	end

	def new
		@plan = Plan.new
	end


# GET /plans/1/edit
def edit

end

def create
	@plan = Plan.new(new_plan_params)
	respond_to do |format|
	begin
			Stripe::Plan.create(
				id: new_plan_params[:stripe_id],
				amount: new_plan_params[:amount].to_i,
				currency: 'usd',
				interval: new_plan_params[:interval],
				name: new_plan_params[:name],
        trial_period_days: new_plan_params[:trial_period_days].to_i
				)

		rescue Stripe::StripeError => e
			puts e.message
			return @plan
		end
		if @plan.save

			format.html { redirect_to @plan, notice: 'Plan was successfully created.' }
			format.json { render :show, status: :created, location: @plan }
		else
			format.html { render :new }
			format.json { render json: @plan.errors, status: :unprocessable_entity }
		end
	end

end

  # PATCH/PUT /plans/1
  # PATCH/PUT /plans/1.json
  def update
      begin
       product = Product.find(plan_params[:product_id])
  		 @plan.update!(product: product)
  		 redirect_to @plan, notice: 'Plan was successfully updated.'
  		rescue
  		render json: @plan.errors, status: :unprocessable_entity 
  	end
  end

  def destroy
    begin
  	 stripe_plan = Stripe::Plan.retrieve(@plan.stripe_id)
	   stripe_plan.delete
    rescue Stripe::StripeError => e
      puts e.message
    end
  	@plan.destroy
  	respond_to do |format|
  		format.html { redirect_to plans_url, notice: 'Plan was successfully destroyed.' }
  		format.json { head :no_content }
  	end

  end

  private
  def set_plan
  	@plan = Plan.find(params[:id])
  end
     # Never trust parameters from the scary internet, only allow the white list through.
     def plan_params
     	params.require(:plan).permit(:product_id)
     end
     def new_plan_params
     	params.require(:plan).permit(:name, :amount, :interval,:stripe_id, :description, :product_id, :trial_period_days)
     end
 end
