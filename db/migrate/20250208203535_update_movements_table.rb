class UpdateMovementsTable < ActiveRecord::Migration[7.2]
  def change
    # 1) Remove the mandatory constraint from branch_id
    change_column_null :movements, :branch_id, true

    # 2) Add a nullable reference to Group
    add_reference :movements, :group, null: true, foreign_key: true
  end
end
