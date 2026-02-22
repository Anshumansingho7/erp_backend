require "test_helper"

class ShopTest < ActiveSupport::TestCase
  def test_shop_belongs_to_company
    shop = shops(:shop_one)
    assert_instance_of Company, shop.company
  end

  def test_shop_has_many_products
    shop = shops(:shop_one)
    assert_kind_of ActiveRecord::Associations::CollectionProxy, shop.products
  end

  def test_shop_has_many_orders
    shop = shops(:shop_one)
    assert_kind_of ActiveRecord::Associations::CollectionProxy, shop.orders
  end

  def test_shop_name_presence
    shop = Shop.new(phone: "1234567890", company: companies(:company_one))
    assert_not shop.valid?
    assert_includes shop.errors[:name], "can't be blank"
  end

  def test_shop_phone_presence
    shop = Shop.new(name: "Test Shop", company: companies(:company_one))
    assert_not shop.valid?
    assert_includes shop.errors[:phone], "can't be blank"
  end

  def test_shop_create_with_valid_attributes
    shop = Shop.new(name: "New Shop", phone: "9876543210", company: companies(:company_one))
    assert shop.valid?
    assert shop.save
  end

  def test_shop_destroy_destroys_associated_products
    # Create a new shop with a product to avoid foreign key constraints
    shop = Shop.create(name: "Test Shop Delete", phone: "9999999999", company: companies(:company_one))
    product = shop.products.create(quantity: 5, discount: 0, master_product: master_products(:master_product_one))
    product_id = product.id
    shop.destroy
    assert_not Product.exists?(product_id)
  end

  def test_shop_destroy_destroys_associated_orders
    # Create a new shop with an order to avoid foreign key constraints
    shop = Shop.create(name: "Test Shop Delete 2", phone: "8888888888", company: companies(:company_one))
    order = shop.orders.create(total_amount: 100.00, customer_name: "Test Customer", customer_phone: "1234567890")
    order_id = order.id
    shop.destroy
    assert_not Order.exists?(order_id)
  end

  def test_shop_has_many_products_count
    shop = shops(:shop_one)
    assert shop.products.count > 0
  end

  def test_shop_has_many_orders_count
    shop = shops(:shop_one)
    assert shop.orders.count > 0
  end
end
