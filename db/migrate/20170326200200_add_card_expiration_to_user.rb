class AddCardExpirationToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :card_expiration, :date
  end
end
