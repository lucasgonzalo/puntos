class CreateMovements < ActiveRecord::Migration[7.1]
  def change
    create_table :movements do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :branch, null: false, foreign_key: true
      t.string :movement_type
      t.decimal :amount
      t.bigint :points

      t.timestamps
    end
  end
end
