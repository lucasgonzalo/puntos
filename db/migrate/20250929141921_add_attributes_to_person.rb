class AddAttributesToPerson < ActiveRecord::Migration[7.2]
  def change
    add_column :people, :old_id, :integer
    add_column :people, :card_number, :string
    add_column :people, :old_created_at, :datetime
  end
end
