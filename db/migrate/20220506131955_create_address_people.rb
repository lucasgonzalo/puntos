class CreateAddressPeople < ActiveRecord::Migration[7.1]
  def change
    create_table :address_people do |t|
      t.references :person, null: false, foreign_key: true
      t.string :address
      t.string :geo_location_link
      t.float :latitude
      t.float :longitude
      t.bigint :postal_code
      t.references :city, null: false, foreign_key: true
      t.boolean :main
      t.boolean :active

      t.timestamps
    end
  end
end
