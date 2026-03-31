class CreateEmailPeople < ActiveRecord::Migration[7.1]
  def change
    create_table :email_people do |t|
      t.references :person, null: false, foreign_key: true
      t.string :email
      t.boolean :active
      t.boolean :main

      t.timestamps
    end
  end
end
