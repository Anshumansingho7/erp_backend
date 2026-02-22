require "test_helper"

class Api::ShopsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @company = companies(:company_one)
    @user = users(:user_one)
    @shop = shops(:shop_one)
    @headers = { "HTTP_AUTHORIZATION" => "Bearer token_for_#{@user.id}" }
  end

  def test_index_shops
    skip "JWT authentication setup required"

    get api_shops_url, headers: @headers

    assert_response :ok
    json = JSON.parse(response.body)
    assert json["shops"].is_a?(Array)
    assert json["total"].is_a?(Integer)
  end

  def test_index_shops_with_pagination
    skip "JWT authentication setup required"

    get api_shops_url, params: { offset: 0, limit: 5 }, headers: @headers

    assert_response :ok
    json = JSON.parse(response.body)
    assert json["shops"].is_a?(Array)
    assert_equal 5, json["shops"].length if json["total"] >= 5
  end

  def test_show_shop
    skip "JWT authentication setup required"

    get api_shop_url(@shop), headers: @headers

    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal @shop.id, json["id"]
    assert_equal @shop.name, json["name"]
  end

  def test_show_nonexistent_shop
    skip "JWT authentication setup required"

    get api_shop_url(999999), headers: @headers

    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal "Shop not found", json["error"]
  end

  def test_create_shop_with_valid_attributes
    skip "JWT authentication setup required"

    post api_shops_url, params: {
      shop: {
        name: "New Shop",
        phone: "1111111111"
      }
    }, headers: @headers

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "New Shop", json["shop"]["name"]
    assert_equal "1111111111", json["shop"]["phone"]
  end

  def test_create_shop_with_missing_name
    skip "JWT authentication setup required"

    post api_shops_url, params: {
      shop: {
        phone: "1111111111"
      }
    }, headers: @headers

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json["errors"].any? { |e| e.include?("Name can't be blank") }
  end

  def test_create_shop_with_missing_phone
    skip "JWT authentication setup required"

    post api_shops_url, params: {
      shop: {
        name: "New Shop"
      }
    }, headers: @headers

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json["errors"].any? { |e| e.include?("Phone can't be blank") }
  end

  def test_update_shop_with_valid_attributes
    skip "JWT authentication setup required"

    patch api_shop_url(@shop), params: {
      shop: {
        name: "Updated Shop Name"
      }
    }, headers: @headers

    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal "Updated Shop Name", json["shop"]["name"]
  end

  def test_update_nonexistent_shop
    skip "JWT authentication setup required"

    patch api_shop_url(999999), params: {
      shop: {
        name: "Updated Name"
      }
    }, headers: @headers

    assert_response :not_found
  end

  def test_destroy_shop
    skip "JWT authentication setup required"

    shop = shops(:shop_two)
    delete api_shop_url(shop), headers: @headers

    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal "Shop deleted", json["message"]
    assert_not Shop.exists?(shop.id)
  end

  def test_destroy_nonexistent_shop
    skip "JWT authentication setup required"

    delete api_shop_url(999999), headers: @headers

    assert_response :not_found
  end
end
