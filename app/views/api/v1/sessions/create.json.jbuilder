json.token @user.api_token
json.token_type "Bearer"
json.user do
  json.extract! @user, :id, :name, :email_address
end
json.client do
  json.extract! @user.client, :id, :business_name
end
