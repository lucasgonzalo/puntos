class DeleteConversionOfCompany < ActiveRecord::Migration[7.1]
  def change
    remove_column :companies, :conversion, :decimal
  end
end
