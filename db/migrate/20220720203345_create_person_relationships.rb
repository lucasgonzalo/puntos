class CreatePersonRelationships < ActiveRecord::Migration[7.1]
  def change
    create_table :person_relationships do |t|
      t.references :person, null: false, foreign_key: true
      t.references :relationship, null: false, foreign_key: true
      t.timestamps
    end
  end
end
