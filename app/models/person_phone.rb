class PersonPhone < ApplicationRecord
  belongs_to :person

  enum phone_type: {personal: 'Particular', labor: 'Laboral', permanent: 'Fijo', others: 'Otros' }

  # enum country_code: {
  #   argentina: ['+54', 'ARG'], uruguay:['+598', 'URY'],
  #   paraguay: ['+595', 'PRY'], chile: ['+56', 'CHL'],
  #   bolivia: ['+591', 'BOL'], brasil: ['+55', 'BRA']
  # }
  enum country_code: {
    argentina: '+54',
    uruguay: '+598',
    paraguay: '+595',
    chile: '+56',
    bolivia: '+591',
    brasil: '+55'
  }

  validates :phone_number, presence: true
  validates :phone_number, uniqueness: { scope: :person, case_sensitive: false }

  before_validation :strip_whitespace
  def strip_whitespace
    self.phone_number = phone_number.strip unless phone_number.nil?
  end

  before_save :check_main
  def check_main
    return unless main?

    person.person_phones.where(main: true).each do |person_phone|
      if person_phone != self
        person_phone.main = false
        person_phone.save!
      end
    end
  end
end
