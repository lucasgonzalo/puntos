class AddColumnNamePeople < ActiveRecord::Migration[7.1]
  def change
    add_column :customers, :status, :string
    add_column :people, :status, :string
  end
end
