require "test_helper"
require_relative "api_test_helper"

class Api::V1::SessionsControllerTest < ActionDispatch::IntegrationTest
  include ApiTestHelper

  test "login returns a new token for a portal user" do
    post api_v1_login_path, params: { email_address: "portal@acme.com.ar", password: "password" }, as: :json

    assert_response :created
    assert_equal users(:acme_portal).reload.api_token, json["token"]
    assert_not_equal "acme-token", json["token"]
  end

  test "login rejects a wrong password" do
    post api_v1_login_path, params: { email_address: "portal@acme.com.ar", password: "nope" }, as: :json

    assert_response :unauthorized
  end

  test "team members cannot log into the API" do
    post api_v1_login_path, params: { email_address: "admin@example.com", password: "password" }, as: :json

    assert_response :unauthorized
  end

  test "logout invalidates the token" do
    delete api_v1_logout_path, headers: auth_headers(users(:acme_portal))
    assert_response :no_content

    get api_v1_projects_path, headers: { "Authorization" => "Bearer acme-token" }
    assert_response :unauthorized
  end
end
