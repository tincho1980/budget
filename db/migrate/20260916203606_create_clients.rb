class CreateClients < ActiveRecord::Migration[8.1]
  def change
    create_table :clients do |t|
      t.string :business_name, null: false
      t.string :contact_name
      t.string :email
      t.string :tax_id
      t.string :phone
      t.boolean :active, default: true, null: false

      t.timestamps
    end
    add_index :clients, :tax_id, unique: true
  end
end
