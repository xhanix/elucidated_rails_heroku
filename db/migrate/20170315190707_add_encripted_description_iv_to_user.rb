class AddEncriptedDescriptionIvToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :encrypted_description_iv, :string
  end
end
