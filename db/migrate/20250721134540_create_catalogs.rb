class CreateCatalogs < ActiveRecord::Migration[7.2]
  def change
    create_table :catalogs do |t|
      t.string :name
      t.references :group, null: false, foreign_key: true
      t.references :company, null: true, foreign_key: true
      t.text :description

      t.timestamps
    end
  end
end
