class AddProductRefToPlans < ActiveRecord::Migration[5.0]
  def change
    add_reference :plans, :product, foreign_key: true
  end
end
