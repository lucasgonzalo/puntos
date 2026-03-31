class AddDescriptionToMovements < ActiveRecord::Migration[7.2]
  def change
    add_column :movements, :description, :text
  end
end
