class AddMailDeliveredToMovements < ActiveRecord::Migration[7.2]
  def change
    add_column :movements, :mail_delivered_at, :datetime
  end
end
