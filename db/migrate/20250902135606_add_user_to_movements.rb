class AddUserToMovements < ActiveRecord::Migration[7.2]
  def change
    add_reference :movements, :user, null: true, foreign_key: true
  end
end
