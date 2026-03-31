json.extract! customer, :id, :person_id, :company_id, :active, :created_at, :updated_at
json.url customer_url(customer, format: :json)
