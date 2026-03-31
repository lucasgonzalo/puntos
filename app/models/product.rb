class Product < ApplicationRecord

  enum product_type: { points: "PUNTOS", currency_points: "PUNTOSPESOS" }, _prefix: true

  has_many :catalog_products, dependent: :destroy
  has_many :catalogs, through: :catalog_products

   has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_limit: [377, 134]
  end

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  validates :name, presence: true

  def get_type
    return 'SIN TIPO' unless product_type

    Product.product_types[product_type]
  end
end
