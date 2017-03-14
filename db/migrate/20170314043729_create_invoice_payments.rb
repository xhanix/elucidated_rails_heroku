class CreateInvoicePayments < ActiveRecord::Migration[5.0]
  def change
    create_table :invoice_payments do |t|
      t.string :stripe_id
      t.integer :amount
      t.integer :fee_amount
      t.references :user, foreign_key: true
      t.references :subscription, foreign_key: true

      t.timestamps
    end
  end
end
