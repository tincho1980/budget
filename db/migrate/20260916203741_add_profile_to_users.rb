class AddProfileToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :name, :string
    add_column :users, :role, :integer
    add_column :users, :level, :integer
    add_column :users, :api_token, :string
    add_index :users, :api_token, unique: true
    add_reference :users, :client, null: false, foreign_key: true
  end
end
