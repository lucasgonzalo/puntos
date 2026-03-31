class UpdateMovementsTablePerson < ActiveRecord::Migration[7.2]
  def change
     # 1) Allow null values in customer_id
     change_column_null :movements, :customer_id, true

     # 2) Add reference to Person model
     add_reference :movements, :person, null: true, foreign_key: true
  end
end
