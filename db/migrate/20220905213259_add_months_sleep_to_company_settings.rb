class AddMonthsSleepToCompanySettings < ActiveRecord::Migration[7.1]
  def change
    add_column :companies, :months_sleep, :integer
  end
end
