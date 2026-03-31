class CreateGroupUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :group_users, if_not_exists: true do |t|
      t.references :group, null: false, foreign_key: true if
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
