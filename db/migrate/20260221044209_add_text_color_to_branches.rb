class AddTextColorToBranches < ActiveRecord::Migration[7.2]
  def change
    add_column :branches, :email_text_color, :string
  end
end
