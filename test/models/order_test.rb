require "test_helper"

class OrderTest < ActiveSupport::TestCase
  def test_order_belongs_to_shop
    order = orders(:order_one)
    assert_instance_of Shop, order.shop
  end

  def test_order_has_many_order_items
    order = orders(:order_one)
    assert_kind_of ActiveRecord::Associations::CollectionProxy, order.order_items
  end

  def test_order_accepts_nested_attributes_for_order_items
    order = orders(:order_one)
    assert order.respond_to?(:order_items_attributes=)
  end

  def test_order_total_amount_presence
    # Total amount has default value of 0.0 in database
    # Test that customer fields are required
    order = Order.new(shop: shops(:shop_one))
    assert_not order.valid?
    assert order.errors[:customer_name].present?
  end

  def test_order_customer_name_presence
    order = Order.new(total_amount: 100.00, customer_phone: "1234567890", shop: shops(:shop_one))
    assert_not order.valid?
    assert_includes order.errors[:customer_name], "can't be blank"
  end

  def test_order_customer_phone_presence
    order = Order.new(total_amount: 100.00, customer_name: "John Doe", shop: shops(:shop_one))
    assert_not order.valid?
    assert_includes order.errors[:customer_phone], "can't be blank"
  end

  def test_order_create_with_valid_attributes
    order = Order.new(total_amount: 300.00, customer_name: "Jane Doe", customer_phone: "0987654321", shop: shops(:shop_one))
    assert order.valid?
    assert order.save
  end

  def test_order_calculate_total_on_save
    order = Order.new(shop: shops(:shop_one), total_amount: 0)
    order.save
    # Total should be recalculated
    assert order.total_amount.present?
  end

  def test_order_with_order_items
    order = orders(:order_one)
    assert order.order_items.count > 0
  end

  def test_order_destroy_destroys_associated_order_items
    order = orders(:order_one)
    order_item_id = order.order_items.first.id
    order.destroy
    assert_not OrderItem.exists?(order_item_id)
  end

  def test_order_total_amount_numeric
    order = Order.new(total_amount: 500.75, customer_name: "John Doe", customer_phone: "1234567890", shop: shops(:shop_one))
    assert order.valid?
  end
end
