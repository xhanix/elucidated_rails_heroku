class AddBraintreeSubIdToSubscription < ActiveRecord::Migration[5.0]
  def change
    add_column :subscriptions, :braintree_id, :string
  end
end
