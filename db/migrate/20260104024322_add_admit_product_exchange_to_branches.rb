class AddAdmitProductExchangeToBranches < ActiveRecord::Migration[7.2]
  def change
    add_column :branches, :admits_product_exchange, :boolean, default: false
  end
end
