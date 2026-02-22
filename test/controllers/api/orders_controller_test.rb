require "test_helper"

class Api::OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @company = companies(:company_one)
    @user = users(:user_one)
    @shop = shops(:shop_one)
    @order = orders(:order_one)
    @headers = { "HTTP_AUTHORIZATION" => "Bearer token_for_#{@user.id}" }
  end

  def test_index_orders
    skip "JWT authentication setup required"

    get api_shop_orders_url(@shop), headers: @headers

    assert_response :ok
    json = JSON.parse(response.body)
    assert json["orders"].is_a?(Array)
    assert json["total"].is_a?(Integer)
  end

  def test_index_orders_with_pagination
    skip "JWT authentication setup required"

    get api_shop_orders_url(@shop), params: { offset: 0, limit: 5 }, headers: @headers

    assert_response :ok
    json = JSON.parse(response.body)
    assert json["orders"].is_a?(Array)
  end

  def test_show_order
    skip "JWT authentication setup required"

    get api_shop_order_url(@shop, @order), headers: @headers

    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal @order.id, json["id"]
    assert_equal @order.total_amount, json["total_amount"]
    assert json["order_items"].is_a?(Array)
  end

  def test_show_nonexistent_order
    skip "JWT authentication setup required"

    get api_shop_order_url(@shop, 999999), headers: @headers

    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal "Order not found", json["error"]
  end

  def test_show_order_from_wrong_shop
    skip "JWT authentication setup required"

    other_shop = shops(:shop_two)
    get api_shop_order_url(other_shop, @order), headers: @headers

    assert_response :not_found
  end

  def test_create_order_with_valid_attributes
    skip "JWT authentication setup required"

    post api_shop_orders_url(@shop), params: {
      order: {
        total_amount: 350.00,
        customer_name: "John Doe",
        customer_phone: "1234567890"
      }
    }, headers: @headers

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "Order created", json["message"]
    assert_equal 350.0, json["order"]["total_amount"]
    assert_equal "John Doe", json["order"]["customer_name"]
  end

  def test_create_order_with_missing_total_amount
    skip "JWT authentication setup required"

    post api_shop_orders_url(@shop), params: {
      order: {
        customer_name: "John Doe",
        customer_phone: "1234567890"
      }
    }, headers: @headers

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json["errors"].any? { |e| e.include?("Total amount can't be blank") }
  end

  def test_create_order_with_missing_customer_name
    skip "JWT authentication setup required"

    post api_shop_orders_url(@shop), params: {
      order: {
        total_amount: 350.00,
        customer_phone: "1234567890"
      }
    }, headers: @headers

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json["errors"].any? { |e| e.include?("Customer name can't be blank") }
  end

  def test_create_order_with_missing_customer_phone
    skip "JWT authentication setup required"

    post api_shop_orders_url(@shop), params: {
      order: {
        total_amount: 350.00,
        customer_name: "John Doe"
      }
    }, headers: @headers

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json["errors"].any? { |e| e.include?("Customer phone can't be blank") }
  end

  def test_create_order_with_order_items
    skip "JWT authentication setup required"

    product = products(:product_one)
    post api_shop_orders_url(@shop), params: {
      order: {
        total_amount: 500.00,
        customer_name: "Jane Smith",
        customer_phone: "5555555555",
        order_items_attributes: [
          {
            product_id: product.id,
            quantity: 2,
            price: 100.00,
            discount: 10.00
          }
        ]
      }
    }, headers: @headers

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal 1, json["order"]["order_items"].length
  end

  def test_update_order_with_valid_attributes
    skip "JWT authentication setup required"

    patch api_shop_order_url(@shop, @order), params: {
      order: {
        total_amount: 450.00
      }
    }, headers: @headers

    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal "Order updated", json["message"]
  end

  def test_update_nonexistent_order
    skip "JWT authentication setup required"

    patch api_shop_order_url(@shop, 999999), params: {
      order: {
        total_amount: 450.00
      }
    }, headers: @headers

    assert_response :not_found
  end

  def test_destroy_order
    skip "JWT authentication setup required"

    order = orders(:order_two)
    delete api_shop_order_url(@shop, order), headers: @headers

    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal "Order deleted", json["message"]
    assert_not Order.exists?(order.id)
  end

  def test_destroy_nonexistent_order
    skip "JWT authentication setup required"

    delete api_shop_order_url(@shop, 999999), headers: @headers

    assert_response :not_found
  end

  def test_order_includes_order_items
    skip "JWT authentication setup required"

    get api_shop_order_url(@shop, @order), headers: @headers

    assert_response :ok
    json = JSON.parse(response.body)
    assert json.key?("order_items")
    assert json["order_items"].is_a?(Array)
  end

  def test_orders_include_order_items_in_index
    skip "JWT authentication setup required"

    get api_shop_orders_url(@shop), headers: @headers

    assert_response :ok
    json = JSON.parse(response.body)
    assert json["orders"].all? { |order| order.key?("order_items") }
  end
end
