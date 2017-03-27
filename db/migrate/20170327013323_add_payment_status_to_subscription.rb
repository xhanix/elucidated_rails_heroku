class AddPaymentStatusToSubscription < ActiveRecord::Migration[5.0]
  def change
    add_column :subscriptions, :payment_status, :string
  end
end
