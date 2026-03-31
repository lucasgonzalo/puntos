class CreateCatalogProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :catalog_products do |t|
      t.references :catalog, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
