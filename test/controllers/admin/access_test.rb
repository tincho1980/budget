require "test_helper"

class Admin::AccessTest < ActionDispatch::IntegrationTest
  test "the back-office requires a login" do
    get admin_clients_path

    assert_redirected_to new_session_path
  end

  test "portal users cannot enter the back-office" do
    sign_in_as(users(:acme_portal))
    get admin_clients_path

    assert_redirected_to new_session_path
  end

  test "team members can list and create clients" do
    sign_in_as(users(:developer))
    get admin_clients_path
    assert_response :success

    assert_difference -> { Client.count }, 1 do
      post admin_clients_path, params: { client: { business_name: "Nuevo SA", tax_id: "30-33333333-3" } }
    end
  end

  test "an invalid client re-renders the form with a 422" do
    sign_in_as(users(:developer))
    post admin_clients_path, params: { client: { business_name: "" } }

    assert_response :unprocessable_content
  end

  test "a client with projects cannot be deleted" do
    sign_in_as(users(:admin))

    assert_no_difference -> { Client.count } do
      delete admin_client_path(clients(:acme))
    end
  end

  test "only admins manage users" do
    sign_in_as(users(:developer))
    get admin_users_path

    assert_redirected_to admin_root_path
  end
end
