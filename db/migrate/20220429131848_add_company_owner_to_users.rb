class AddCompanyOwnerToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :company_owner_role, :boolean, default: false
  end
end
