class AddEncriptedDescriptionToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :encrypted_description, :string
  end
end
