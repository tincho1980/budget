class CreateBudgetItems < ActiveRecord::Migration[8.1]
  def change
    create_table :budget_items do |t|
      t.references :budget, null: false, foreign_key: true
      t.references :rate, null: false, foreign_key: true
      t.string :module_name
      t.string :description, null: false
      t.decimal :estimated_hours, precision: 8, scale: 2, null: false
      t.integer :level, null: false
      t.boolean :billable, default: true, null: false
      t.integer :position

      t.timestamps
    end
  end
end
