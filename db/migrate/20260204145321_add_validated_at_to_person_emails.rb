class AddValidatedAtToPersonEmails < ActiveRecord::Migration[7.2]
  def change
    add_column :person_emails, :validated_at, :datetime
    add_column :person_emails, :email_validation_times_sended, :integer
    add_column :person_emails, :emails_sended, :integer, default: 0
  end
end
