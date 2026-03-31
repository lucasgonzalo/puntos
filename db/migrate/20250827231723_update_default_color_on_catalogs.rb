class UpdateDefaultColorOnCatalogs < ActiveRecord::Migration[7.2]
  def up
    # Update existing records that have "white" to "#FFFFFF"
    execute "UPDATE catalogs SET text_color = '#FFFFFF' WHERE text_color = 'white'"
    
    # Change the column default for future records
    change_column_default :catalogs, :text_color, from: "white", to: "#FFFFFF"
  end

  def down
    # Revert existing records back to "white"
    execute "UPDATE catalogs SET text_color = 'white' WHERE text_color = '#FFFFFF'"
    
    # Revert the column default
    change_column_default :catalogs, :text_color, from: "#FFFFFF", to: "white"
  end
end
