class AddColorAndBackgroundImageToCatalogs < ActiveRecord::Migration[7.2]
  def change
    add_column :catalogs, :text_color, :string, default: "white"
    add_column :catalogs, :background_color, :string, default: "#0dcaf0"
  end
end
