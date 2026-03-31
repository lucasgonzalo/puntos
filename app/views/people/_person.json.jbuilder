json.extract! person, :id, :first_name, :last_name, :document_type, :document_number, :birth_date, :gender, :created_at, :updated_at
json.url person_url(person, format: :json)
