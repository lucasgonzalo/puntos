class CompanySetting < ApplicationRecord

  # ------------------------------Relaciones---------------------------------------------
  belongs_to :company
  validate :check_max_discount # Adds a validation method or block to the class
  before_save :default_value_conversion

  # ------------------------------Metodos---------------------------------------------
  def check_max_discount
    errors.add(:base, 'El valor del Descuento debe ser Menor que 100') if discount.negative? || discount > 100
  end

  def default_value_conversion
    conversion = 0 if conversion.blank?
  end

end
