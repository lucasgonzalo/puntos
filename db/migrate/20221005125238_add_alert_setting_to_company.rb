class AddAlertSettingToCompany < ActiveRecord::Migration[7.1]
  def change
    add_column :companies, :alert_days, :integer
    add_column :companies, :alert_qty_movements, :decimal
    add_column :companies, :alert_amount, :decimal
  end
end
