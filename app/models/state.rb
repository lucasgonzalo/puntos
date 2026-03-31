class State < ApplicationRecord
  belongs_to :country
  has_many :cities

  validates :name, presence: true, length: { minimum: 3 }
  validates :name, uniqueness: { scope: :country, case_sensitive: false }

  default_scope { order(:name) }
end
