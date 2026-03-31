json.extract! movement, :id, :customer_id, :branch_id, :movement_type, :amount, :points, :created_at, :updated_at
json.url movement_url(movement, format: :json)