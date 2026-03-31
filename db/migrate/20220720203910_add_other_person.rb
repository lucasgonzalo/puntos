class AddOtherPerson < ActiveRecord::Migration[7.1]
  def change
    add_reference :person_relationships, :person_relation, foreign_key: {to_table: :people}
  end
end
