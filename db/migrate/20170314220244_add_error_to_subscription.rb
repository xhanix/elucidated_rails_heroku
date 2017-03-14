class AddErrorToSubscription < ActiveRecord::Migration[5.0]
  def change
    add_column :subscriptions, :error, :text
  end
end
