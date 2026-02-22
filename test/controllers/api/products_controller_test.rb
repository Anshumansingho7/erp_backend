require "test_helper"

class Api::ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @company = companies(:company_one)
    @user = users(:user_one)
    @shop = shops(:shop_one)
    @product = products(:product_one)
    @master_product = master_products(:master_product_one)
    @headers = { "HTTP_AUTHORIZATION" => "Bearer token_for_#{@user.id}" }
  end

  def test_index_products
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    get api_shop_products_url(@shop), headers: @headers

    assert_response :ok
    json = JSON.parse(response.body)
    assert json["products"].is_a?(Array)
    assert json["total"].is_a?(Integer)
  end

  def test_index_products_with_pagination
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    get api_shop_products_url(@shop), params: { offset: 0, limit: 5 }, headers: @headers

    assert_response :ok
    json = JSON.parse(response.body)
    assert json["products"].is_a?(Array)
  end

  def test_show_product
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    get api_shop_product_url(@shop, @product), headers: @headers

    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal @product.id, json["id"]
    assert json["price"].present?
  end

  def test_show_nonexistent_product
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    get api_shop_product_url(@shop, 999999), headers: @headers

    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal "Product not found", json["error"]
  end

  def test_show_product_from_wrong_shop
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    other_shop = shops(:shop_two)
    get api_shop_product_url(other_shop, @product), headers: @headers

    assert_response :not_found
  end

  def test_create_product_with_valid_attributes
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    post api_shop_products_url(@shop), params: {
      product: {
        quantity: 30,
        discount: 12.50,
        master_product_id: @master_product.id
      }
    }, headers: @headers

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal 30, json["product"]["quantity"]
    assert_equal 12.50, json["product"]["discount"]
    assert json["product"]["price"].present?
  end

  def test_create_product_with_missing_quantity
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    post api_shop_products_url(@shop), params: {
      product: {
        discount: 12.50,
        master_product_id: @master_product.id
      }
    }, headers: @headers

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json["errors"].any? { |e| e.include?("Quantity can't be blank") }
  end

  def test_create_product_with_missing_discount
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    post api_shop_products_url(@shop), params: {
      product: {
        quantity: 30,
        master_product_id: @master_product.id
      }
    }, headers: @headers

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json["errors"].any? { |e| e.include?("Discount can't be blank") }
  end

  def test_create_product_with_negative_discount
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    post api_shop_products_url(@shop), params: {
      product: {
        quantity: 30,
        discount: -10.00,
        master_product_id: @master_product.id
      }
    }, headers: @headers

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json["errors"].any? { |e| e.include?("Discount must be greater than or equal to 0") }
  end

  def test_update_product_with_valid_attributes
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    patch api_shop_product_url(@shop, @product), params: {
      product: {
        quantity: 50
      }
    }, headers: @headers

    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal 50, json["product"]["quantity"]
  end

  def test_update_nonexistent_product
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    patch api_shop_product_url(@shop, 999999), params: {
      product: {
        quantity: 50
      }
    }, headers: @headers

    assert_response :not_found
  end

  def test_destroy_product
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    product = products(:product_two)
    delete api_shop_product_url(@shop, product), headers: @headers

    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal "Deleted successfully", json["message"]
    assert_not Product.exists?(product.id)
  end

  def test_destroy_nonexistent_product
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    delete api_shop_product_url(@shop, 999999), headers: @headers

    assert_response :not_found
  end

  def test_product_price_in_response
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    get api_shop_product_url(@shop, @product), headers: @headers

    assert_response :ok
    json = JSON.parse(response.body)
    expected_price = @master_product.price - @product.discount
    assert_equal expected_price, json["price"]
  end
end
