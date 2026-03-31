class AddLastUpdateCustomersToCompanies < ActiveRecord::Migration[7.2]
  def change
    add_column :companies, :last_update_customers_job, :datetime
  end
end
