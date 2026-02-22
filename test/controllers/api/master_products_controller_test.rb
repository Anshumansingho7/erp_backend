require "test_helper"

class Api::MasterProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @company = companies(:company_one)
    @user = users(:user_one)
    @master_product = master_products(:master_product_one)
    @headers = { "HTTP_AUTHORIZATION" => "Bearer token_for_#{@user.id}" }
  end

  def test_index_master_products
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    get api_master_products_url, headers: @headers

    assert_response :ok
    json = JSON.parse(response.body)
    assert json["products"].is_a?(Array)
    assert json["total"].is_a?(Integer)
  end

  def test_index_master_products_with_pagination
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    get api_master_products_url, params: { offset: 0, limit: 5 }, headers: @headers

    assert_response :ok
    json = JSON.parse(response.body)
    assert json["products"].is_a?(Array)
  end

  def test_show_master_product
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    get api_master_product_url(@master_product), headers: @headers

    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal @master_product.id, json["id"]
    assert_equal @master_product.name, json["name"]
    assert_equal @master_product.sku, json["sku"]
  end

  def test_show_nonexistent_master_product
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    get api_master_product_url(999999), headers: @headers

    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal "Product not found", json["error"]
  end

  def test_create_master_product_with_valid_attributes
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    post api_master_products_url, params: {
      master_product: {
        name: "New Master Product",
        sku: "SKU_NEW_001",
        price: 250.00
      }
    }, headers: @headers

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "New Master Product", json["product"]["name"]
    assert_equal "SKU_NEW_001", json["product"]["sku"]
    assert_equal 250.0, json["product"]["price"]
  end

  def test_create_master_product_with_missing_name
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    post api_master_products_url, params: {
      master_product: {
        sku: "SKU_NEW_002",
        price: 250.00
      }
    }, headers: @headers

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json["errors"].any? { |e| e.include?("Name can't be blank") }
  end

  def test_create_master_product_with_missing_sku
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    post api_master_products_url, params: {
      master_product: {
        name: "New Master Product",
        price: 250.00
      }
    }, headers: @headers

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json["errors"].any? { |e| e.include?("Sku can't be blank") }
  end

  def test_create_master_product_with_duplicate_sku
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    post api_master_products_url, params: {
      master_product: {
        name: "Another Product",
        sku: @master_product.sku,
        price: 250.00
      }
    }, headers: @headers

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json["errors"].any? { |e| e.include?("has already been taken") }
  end

  def test_create_master_product_with_missing_price
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    post api_master_products_url, params: {
      master_product: {
        name: "New Master Product",
        sku: "SKU_NEW_003"
      }
    }, headers: @headers

    assert_response :unprocessable_entity
  end

  def test_update_master_product_with_valid_attributes
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    patch api_master_product_url(@master_product), params: {
      master_product: {
        name: "Updated Master Product Name"
      }
    }, headers: @headers

    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal "Updated Master Product Name", json["product"]["name"]
  end

  def test_update_nonexistent_master_product
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    patch api_master_product_url(999999), params: {
      master_product: {
        name: "Updated Name"
      }
    }, headers: @headers

    assert_response :not_found
  end

  def test_destroy_master_product
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    master_product = master_products(:master_product_two)
    delete api_master_product_url(master_product), headers: @headers

    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal "Product deleted", json["message"]
    assert_not MasterProduct.exists?(master_product.id)
  end

  def test_destroy_nonexistent_master_product
    skip "JWT authentication setup required" if ENV["SKIP_AUTH_TESTS"]

    delete api_master_product_url(999999), headers: @headers

    assert_response :not_found
  end
end
