class AddDateRemindedToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :date_reminded, :date
  end
end
