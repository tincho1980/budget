class CreateRates < ActiveRecord::Migration[8.1]
  def change
    create_table :rates do |t|
      t.integer :level, null: false
      t.decimal :hourly_value, precision: 12, scale: 2, null: false
      t.date :valid_from, null: false

      t.timestamps
    end
    add_index :rates, [ :level, :valid_from ], unique: true
  end
end
