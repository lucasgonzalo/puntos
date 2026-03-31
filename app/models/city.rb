class City < ApplicationRecord

  # ------------------------------Relaciones---------------------------------------------

  belongs_to :state

  validates :name, presence: true, length: { minimum: 3 }
  validates :name, uniqueness: { scope: :state, case_sensitive: false }

  default_scope { order(:name) }

  # ------------------------------Métodos---------------------------------------------

  def full_name
    "#{self.name} - #{self.state.name} - #{self.state.country.name}"
  end
end
