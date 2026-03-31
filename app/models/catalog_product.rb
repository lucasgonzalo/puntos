class CatalogProduct < ApplicationRecord
  belongs_to :catalog
  belongs_to :product
end
