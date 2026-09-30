require "test_helper"
require_relative "api_test_helper"

class Api::V1::AccessTest < ActionDispatch::IntegrationTest
  include ApiTestHelper

  test "every endpoint requires a token" do
    [ api_v1_projects_path, api_v1_account_path, api_v1_charges_path, api_v1_budget_path(budgets(:acme_sent)) ].each do |path|
      get path
      assert_response :unauthorized, "#{path} should require a token"
    end
  end

  test "a team member's token is not valid for the API" do
    get api_v1_projects_path, headers: auth_headers(users(:admin))

    assert_response :unauthorized
  end

  test "a client only sees its own projects" do
    get api_v1_projects_path, headers: auth_headers(users(:acme_portal))

    assert_response :success
    assert_equal [ "Proyecto cerrado", "Sitio web Acme" ], json["projects"].map { |project| project["name"] }.sort
  end

  test "another client's project is not found, not forbidden" do
    get api_v1_project_path(projects(:globex_app)), headers: auth_headers(users(:acme_portal))

    assert_response :not_found
  end

  test "another client's budget cannot be approved" do
    post approve_api_v1_budget_path(budgets(:globex_sent)), headers: auth_headers(users(:acme_portal))

    assert_response :not_found
    assert budgets(:globex_sent).reload.sent?
  end

  test "draft budgets are not visible to the client" do
    get api_v1_budget_path(budgets(:acme_draft)), headers: auth_headers(users(:acme_portal))

    assert_response :not_found
  end
end
