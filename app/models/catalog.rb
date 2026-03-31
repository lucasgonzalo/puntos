class Catalog < ApplicationRecord

  belongs_to :group
  belongs_to :company, optional: true
  has_many :catalog_products, dependent: :destroy
  has_many :products, through: :catalog_products

  has_one_attached :image_catalog do |attachable|
    attachable.variant :thumb, resize_to_limit: [377, 134] #requires image_processing gem, minimagick or libvips
  end

  has_one_attached :background_image do |attachable|
    attachable.variant :thumb, resize_to_limit: [377, 134] #requires image_processing gem, minimagick or libvips
  end

  attr_accessor :remove_image_catalog, :remove_background_image

  before_save :purge_image_if_needed
  before_save :purge_background_image_if_needed

  private

  def purge_image_if_needed
    image_catalog.purge if remove_image_catalog == "1"
  end

  def purge_background_image_if_needed
    background_image.purge if remove_background_image == "1"
  end
end
