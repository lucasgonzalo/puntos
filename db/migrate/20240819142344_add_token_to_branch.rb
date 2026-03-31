class AddTokenToBranch < ActiveRecord::Migration[7.1]
  def change
    add_column :branches, :token, :string
  end
end
