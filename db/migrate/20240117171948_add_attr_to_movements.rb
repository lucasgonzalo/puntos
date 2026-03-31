class AddAttrToMovements < ActiveRecord::Migration[7.1]
  def change
    add_column :movements, :total_import, :decimal
  end
end
