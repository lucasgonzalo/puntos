class AddAdmitsExchangeToBranches < ActiveRecord::Migration[7.2]
  def change
    add_column :branches, :admits_exchange, :boolean, default: false
  end
end
