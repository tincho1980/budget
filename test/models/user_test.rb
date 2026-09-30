require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "new users get the lowest access level by default" do
    assert User.new.role_client?
  end

  test "portal users need a client and team members must not have one" do
    assert_not User.new(name: "x", email_address: "x@x.com", password: "secret123").valid?
    assert_not User.new(name: "y", email_address: "y@y.com", password: "secret123", role: :developer, client: clients(:acme)).valid?
  end

  test "an unknown role is a validation error, not an exception" do
    user = users(:admin)
    user.role = :superadmin

    assert_not user.valid?
  end
end
