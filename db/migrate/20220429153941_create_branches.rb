class CreateBranches < ActiveRecord::Migration[7.1]
  def change
    create_table :branches do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name
      t.string :address
      t.references :city, null: false, foreign_key: true
      t.string :geolocation_link
      t.boolean :main, default: false
      t.boolean :active, default: false

      t.timestamps
    end
  end
end
