class PersonEmail < ApplicationRecord
  belongs_to :person

  validates :email, presence: true
  validates :email, uniqueness: { scope: :person, case_sensitive: false }

  before_validation :strip_whitespace
  def strip_whitespace
    self.email = self.email.strip unless self.email.nil?
  end

  before_save :check_main

  def check_main
    if self.main?
      self.person.person_emails.where(main: true).each do |person_email|
        if person_email != self
          person_email.main = false
          person_email.save!
        end
      end
    end
  end

  generates_token_for :email_validation, expires_in: 48.hours

end
