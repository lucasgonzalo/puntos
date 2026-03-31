class AddUniqueIndexToGroupUsers < ActiveRecord::Migration[7.2]
  def change
    add_index :group_users, [:user_id, :group_id], unique: true
  end
end
