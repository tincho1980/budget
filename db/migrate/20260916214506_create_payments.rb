class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :client, null: false, foreign_key: true
      t.references :registered_by, null: false, foreign_key: { to_table: :users }
      t.date :paid_on, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.integer :payment_method, null: false
      t.integer :status, default: 0, null: false
      t.text :notes

      t.timestamps
    end
  end
end
