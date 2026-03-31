class Country < ApplicationRecord

  # ------------------------------Relaciones---------------------------------------------
  has_many :states

  validates :name, presence: true, length: { minimum: 3 }
  validates :name, uniqueness: { case_sensitive: false }

  default_scope { order(:name) }

  # ------------------------------Métodos---------------------------------------------
  def self.list
    Country.all.order(:name)
  end
end
