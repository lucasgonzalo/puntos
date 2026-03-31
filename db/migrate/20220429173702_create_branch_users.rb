class CreateBranchUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :branch_users do |t|
      t.references :branch, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.boolean :active
      t.boolean :manager_role, default: false
      t.boolean :assistant_role, default: false

      t.timestamps
    end
  end
end
