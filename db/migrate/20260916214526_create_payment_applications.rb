class CreatePaymentApplications < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_applications do |t|
      t.references :payment, null: false, foreign_key: true
      t.references :maintenance_charge, null: false, foreign_key: true
      t.decimal :applied_amount, precision: 12, scale: 2, null: false

      t.timestamps
    end
    add_index :payment_applications, [ :payment_id, :maintenance_charge_id ], unique: true
  end
end
