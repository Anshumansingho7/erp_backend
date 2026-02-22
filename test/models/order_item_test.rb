require "test_helper"

class OrderItemTest < ActiveSupport::TestCase
  def test_order_item_belongs_to_order
    order_item = order_items(:order_item_one)
    assert_instance_of Order, order_item.order
  end

  def test_order_item_belongs_to_product
    order_item = order_items(:order_item_one)
    assert_instance_of Product, order_item.product
  end

  def test_order_item_quantity_presence
    # Quantity has a default value of 1
    order_item = OrderItem.new(price: 100.00, discount: 5.00, order: orders(:order_one), product: products(:product_one))
    # Should be valid since quantity defaults to 1
    order_item.valid?
    assert order_item.respond_to?(:quantity=)
  end

  def test_order_item_quantity_greater_than_zero
    order_item = OrderItem.new(quantity: 0, price: 100.00, discount: 5.00, order: orders(:order_one), product: products(:product_one))
    assert_not order_item.valid?
    assert_includes order_item.errors[:quantity], "must be greater than or equal to 1"
  end

  def test_order_item_price_presence
    # Price has a default value of 0.0
    order_item = OrderItem.new(quantity: 2, discount: 5.00, order: orders(:order_one), product: products(:product_one))
    # Should be valid since price defaults to 0.0
    order_item.valid?
    assert order_item.respond_to?(:price=)
  end

  def test_order_item_discount_presence
    # Discount has a default value of 0.0
    order_item = OrderItem.new(quantity: 2, price: 100.00, order: orders(:order_one), product: products(:product_one))
    # Should be valid since discount defaults to 0.0
    order_item.valid?
    assert order_item.respond_to?(:discount=)
  end

  def test_order_item_discount_non_negative
    order_item = OrderItem.new(quantity: 2, price: 100.00, discount: -5.00, order: orders(:order_one), product: products(:product_one))
    assert_not order_item.valid?
    assert_includes order_item.errors[:discount], "must be greater than or equal to 0"
  end

  def test_order_item_create_with_valid_attributes
    order_item = OrderItem.new(quantity: 3, price: 285.00, discount: 15.00, order: orders(:order_one), product: products(:product_one))
    assert order_item.valid?
    assert order_item.save
  end

  def test_order_item_set_price_from_product
    order_item = OrderItem.new(quantity: 1, order: orders(:order_one), product: products(:product_one), discount: 5.00)
    order_item.valid?
    expected_price = products(:product_one).price * 1 - 5.00
    assert_equal expected_price, order_item.price
  end

  def test_order_item_set_price_from_product_with_quantity
    order_item = OrderItem.new(quantity: 2, order: orders(:order_one), product: products(:product_one), discount: 10.00)
    order_item.valid?
    expected_price = products(:product_one).price * 2 - 10.00
    assert_equal expected_price, order_item.price
  end
end
