class AddStateToSubscription < ActiveRecord::Migration[5.0]
  def change
    add_column :subscriptions, :state, :string
  end
end
