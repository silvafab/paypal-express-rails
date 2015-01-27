json.array!(@donations) do |donation|
  json.extract! donation, :id, :name, :email, :amount
  json.url donation_url(donation, format: :json)
end
