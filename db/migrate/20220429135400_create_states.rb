class CreateStates < ActiveRecord::Migration[7.1]
  def change
    create_table :states do |t|
      t.references :country, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
