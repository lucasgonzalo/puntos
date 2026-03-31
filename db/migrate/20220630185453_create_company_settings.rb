class CreateCompanySettings < ActiveRecord::Migration[7.1]
  def change
    create_table :company_settings do |t|
      t.integer :day
      t.references :company, null: false, foreign_key: true
      t.float :conversion
      t.float :discount

      t.timestamps
    end
  end
end
