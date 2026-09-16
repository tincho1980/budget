class CreateMaintenanceCharges < ActiveRecord::Migration[8.1]
  def change
    create_table :maintenance_charges do |t|
      t.references :maintenance_contract, null: false, foreign_key: true
      t.string :period, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.date :due_on, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end
    add_index :maintenance_charges, [ :maintenance_contract_id, :period ], unique: true
  end
end
