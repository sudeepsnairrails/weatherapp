class CreateAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses do |t|
      t.string :full_address, null: false
      t.string :zip_code, null: false
      t.decimal :latitude, precision: 10, scale: 8, null: false
      t.decimal :longitude, precision: 11, scale: 8, null: false
      t.string :city
      t.string :state

      t.timestamps
    end

    add_index :addresses, :full_address, unique: true
    add_index :addresses, :zip_code
  end
end 