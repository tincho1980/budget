class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.string :name, null: false
      t.integer :role, null: false, default: 50
      t.integer :level
      t.string :api_token
      t.references :client, foreign_key: true

      t.timestamps
    end
    add_index :users, :email_address, unique: true
    add_index :users, :api_token, unique: true
  end
end
