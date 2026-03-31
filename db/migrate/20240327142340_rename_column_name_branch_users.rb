class RenameColumnNameBranchUsers < ActiveRecord::Migration[7.1]
  def change
    rename_column :branch_users, :assistant_role, :basic_role
    add_column :branch_users, :intermediate_role, :boolean, default: false
  end
end
