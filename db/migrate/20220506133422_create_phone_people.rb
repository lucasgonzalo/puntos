class CreatePhonePeople < ActiveRecord::Migration[7.1]
  def change
    create_table :phone_people do |t|
      t.references :person, null: false, foreign_key: true
      t.string :country_code
      t.string :area_code
      t.string :phone_number
      t.string :phone_type
      t.boolean :main
      t.boolean :active

      t.timestamps
    end
  end
end
