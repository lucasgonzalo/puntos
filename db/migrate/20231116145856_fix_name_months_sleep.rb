class FixNameMonthsSleep < ActiveRecord::Migration[7.1]
  def change
    rename_column :companies, :months_sleep, :days_sleep
  end
end
