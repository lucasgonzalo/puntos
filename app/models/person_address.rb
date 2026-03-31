class PersonAddress < ApplicationRecord
  belongs_to :person
  belongs_to :city

  validates :address, presence: true
  validates :address, uniqueness: { scope: [:person, :city], case_sensitive: false }

  before_validation :strip_whitespace
  def strip_whitespace
    self.address = self.address.strip unless self.address.nil?
  end

  before_save :check_main
  def check_main
    if self.main?
      self.person.person_addresses.where(main: true).each do |person_address|
        if person_address != self
          person_address.main = false
          person_address.save!
        end
      end
    end
  end
end
  