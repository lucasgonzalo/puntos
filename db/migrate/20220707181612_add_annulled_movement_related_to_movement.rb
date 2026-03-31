class AddAnnulledMovementRelatedToMovement < ActiveRecord::Migration[7.1]
  def change
    add_column :movements, :annulled, :boolean, default: false
    add_reference :movements, :movement_related, foreign_key: {to_table: :movements}
  end
end
