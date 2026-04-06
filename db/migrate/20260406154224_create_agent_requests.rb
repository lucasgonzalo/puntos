class CreateAgentRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :agent_requests do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :branch, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, default: 'pending', null: false
      t.timestamps
    end
    add_index :agent_requests, :status
    add_index :agent_requests, [:customer_id, :status], name: 'index_agent_requests_on_customer_and_status'
  end
end
