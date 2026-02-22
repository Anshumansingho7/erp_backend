require "test_helper"

class Api::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @company = companies(:company_one)
    @user = users(:user_one)
    @headers = { "HTTP_AUTHORIZATION" => "Bearer token_for_#{@user.id}" }
  end

  def test_user_creation_with_valid_attributes
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    post api_users_url, params: {
      user: {
        email: "newuser@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }, headers: @headers

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "newuser@example.com", json["user"]["email"]
  end

  def test_user_creation_with_invalid_email
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    post api_users_url, params: {
      user: {
        email: "",
        password: "password123",
        password_confirmation: "password123"
      }
    }, headers: @headers

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_includes json["errors"].first, "Email can't be blank"
  end

  def test_user_creation_with_duplicate_email
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    post api_users_url, params: {
      user: {
        email: @user.email,
        password: "password123",
        password_confirmation: "password123"
      }
    }, headers: @headers

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json["errors"].any? { |e| e.include?("has already been taken") }
  end

  def test_user_creation_with_password_mismatch
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    post api_users_url, params: {
      user: {
        email: "anotheruser@example.com",
        password: "password123",
        password_confirmation: "different_password"
      }
    }, headers: @headers

    assert_response :unprocessable_entity
  end
end
