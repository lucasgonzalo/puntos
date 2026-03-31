class AddOtherAttributeTable < ActiveRecord::Migration[7.1]
  def change
    add_column :movements, :amount_discounted, :decimal
    add_column :movements, :conversion, :float
    add_column :movements, :discount, :float
  end
end
