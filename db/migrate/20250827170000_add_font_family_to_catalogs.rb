class AddFontFamilyToCatalogs < ActiveRecord::Migration[7.2]
  def change
  # store a simple font key (e.g. 'Inter', 'Montserrat', 'Lora') instead of a full CSS stack
  add_column :catalogs, :font_family, :string
  end
end
