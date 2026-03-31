class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :customers do |t|
      t.references :person, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.boolean :active, default: false
      t.timestamps
    end
  end
end
