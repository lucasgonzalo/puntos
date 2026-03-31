class AddTypeToGroups < ActiveRecord::Migration[7.2]
  def change
    add_column :groups, :account_type, :string
  end
end
