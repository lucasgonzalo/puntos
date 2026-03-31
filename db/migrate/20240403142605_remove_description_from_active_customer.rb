class RemoveDescriptionFromActiveCustomer < ActiveRecord::Migration[7.1]
  def change
    remove_column :customers, :active, :boolean
  end
end
