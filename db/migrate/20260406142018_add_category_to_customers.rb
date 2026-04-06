class AddCategoryToCustomers < ActiveRecord::Migration[7.2]
  def change
    add_column :customers, :category, :string, default: 'CLIENTE', null: false
  end
end
