class CreateAlerts < ActiveRecord::Migration[7.1]
  def change
    create_table :alerts do |t|
      t.references :company, null: false, foreign_key: true
      t.string :category
      t.string :status
      t.text :content
      t.string :link

      t.timestamps
    end
  end
end
