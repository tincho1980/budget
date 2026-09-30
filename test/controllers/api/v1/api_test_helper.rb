module ApiTestHelper
  def auth_headers(user)
    { "Authorization" => "Bearer #{user.api_token}" }
  end

  def json
    response.parsed_body
  end
end
