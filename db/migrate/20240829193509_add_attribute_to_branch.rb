class AddAttributeToBranch < ActiveRecord::Migration[7.1]
  def change
    add_column :branches, :email_background_color, :string
  end
end
