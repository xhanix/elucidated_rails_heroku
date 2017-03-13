class AddFieldsToSale < ActiveRecord::Migration[5.0]
  def change
    add_column :sales, :state, :string
    add_column :sales, :stripe_token, :string
    add_column :sales, :card_expiration, :date
    add_column :sales, :error, :text
    add_column :sales, :fee_amount, :integer
    add_column :sales, :amount, :integer
  end
end
