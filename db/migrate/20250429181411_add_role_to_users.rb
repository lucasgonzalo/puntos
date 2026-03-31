class AddRoleToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :group_owner_role, :boolean, default: false
  end
end
