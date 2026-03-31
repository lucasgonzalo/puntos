class CreateAttributeConvertion < ActiveRecord::Migration[7.1]
  def change
    add_column :companies, :conversion, :decimal
  end
end
