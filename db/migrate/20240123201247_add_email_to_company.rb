class AddEmailToCompany < ActiveRecord::Migration[7.1]
  def change
    add_column :companies, :email, :string
  end
end
