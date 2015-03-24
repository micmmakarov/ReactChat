json.array!(@messages) do |message|
  json.extract! message, :id, :text, :author
  json.url message_url(message, format: :json)
end
