class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.references :client, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.integer :status, default: 0, null: false
      t.date :started_on
      t.date :closed_on

      t.timestamps
    end
  end
end
