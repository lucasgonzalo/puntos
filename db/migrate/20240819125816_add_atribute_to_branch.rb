class AddAtributeToBranch < ActiveRecord::Migration[7.1]
  def change
    add_column :branches, :days_sleep, :integer
    add_column :branches, :alert_days, :integer
    add_column :branches, :alert_qty_movements, :decimal
    add_column :branches, :alert_amount, :decimal
    add_column :branches, :email, :string
  end
end
