class AddActiveToCustomers < ActiveRecord::Migration[7.1]
  def change
    add_column :customers, :active, :boolean, if_not_exists: true
  end
end
