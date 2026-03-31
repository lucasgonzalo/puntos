class ChangeNameTables < ActiveRecord::Migration[7.1]
  def change
      rename_table :address_people, :person_addresses
      rename_table :phone_people, :person_phones
      rename_table :email_people, :person_emails
  end
end
