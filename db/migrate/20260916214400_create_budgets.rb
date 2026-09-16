class CreateBudgets < ActiveRecord::Migration[8.1]
  def change
    create_table :budgets do |t|
      t.references :project, null: false, foreign_key: true
      t.integer :version, default: 1, null: false
      t.integer :status, default: 0, null: false
      t.decimal :buffer_percentage, precision: 5, scale: 2, default: 0, null: false
      t.decimal :total, precision: 12, scale: 2, default: 0, null: false
      t.datetime :sent_at
      t.datetime :approved_at
      t.text :notes

      t.timestamps
    end
    add_index :budgets, [ :project_id, :version ], unique: true
  end
end
