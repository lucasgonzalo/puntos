class CreatePeople < ActiveRecord::Migration[7.1]
  def change
    create_table :people, if_not_exists: true do |t|
      t.string :first_name
      t.string :last_name
      t.string :document_type
      t.string :document_number
      t.date :birth_date
      t.string :gender
      t.timestamps
    end
  end
end
