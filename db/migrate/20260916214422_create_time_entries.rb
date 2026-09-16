class CreateTimeEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :time_entries do |t|
      t.references :budget_item, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.date :worked_on, null: false
      t.decimal :hours, precision: 8, scale: 2, null: false
      t.string :description

      t.timestamps
    end
  end
end
