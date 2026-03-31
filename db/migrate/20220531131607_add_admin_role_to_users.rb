class AddAdminRoleToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :admin_role, :boolean, default: false
  end
end
