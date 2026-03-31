class CreateCompanyGroup < ActiveRecord::Migration[7.2]
  def change
    create_table :company_groups do |t|
      t.references :company, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.timestamps
    end
  end
end
