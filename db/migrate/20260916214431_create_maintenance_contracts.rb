class CreateMaintenanceContracts < ActiveRecord::Migration[8.1]
  def change
    create_table :maintenance_contracts do |t|
      t.references :client, null: false, foreign_key: true
      t.references :project, null: true, foreign_key: true
      t.decimal :monthly_amount, precision: 12, scale: 2, null: false
      t.integer :due_day, null: false
      t.date :starts_on, null: false
      t.date :ends_on
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
