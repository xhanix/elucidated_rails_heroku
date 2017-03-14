class AddGuidToSubscription < ActiveRecord::Migration[5.0]
  def change
    add_column :subscriptions, :guid, :string
  end
end
