class Relationship < ApplicationRecord
  has_many :person_relationships, dependent: :destroy
  has_many :people, through: :person_relationships

  default_scope { order(:name) }
end
