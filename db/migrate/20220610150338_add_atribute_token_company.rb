class AddAtributeTokenCompany < ActiveRecord::Migration[7.1]
  def change
    add_column :companies, :token, :string
  end
end
