class PersonRelationship < ApplicationRecord
  belongs_to :person
  belongs_to :relationship
  belongs_to :person_relation, optional: true, class_name: 'Person', foreign_key: 'person_relation_id'
end
