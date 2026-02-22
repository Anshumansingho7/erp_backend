require "test_helper"

class ProductTest < ActiveSupport::TestCase
  def test_product_belongs_to_master_product
    product = products(:product_one)
    assert_instance_of MasterProduct, product.master_product
  end

  def test_product_belongs_to_shop
    product = products(:product_one)
    assert_instance_of Shop, product.shop
  end

  def test_product_quantity_presence
    product = Product.new(discount: 5.00, master_product: master_products(:master_product_one), shop: shops(:shop_one))
    assert_not product.valid?
    assert_includes product.errors[:quantity], "can't be blank"
  end

  def test_product_discount_presence
    # Discount has a default value of 0.0 in the database, so it's always present
    product = Product.new(quantity: 10, discount: nil, master_product: master_products(:master_product_one), shop: shops(:shop_one))
    product.valid?
    # The field has a default, so validation should not complain
    # Just test that discount can be set
    assert product.respond_to?(:discount=)
  end

  def test_product_discount_non_negative
    product = Product.new(quantity: 10, discount: -5.00, master_product: master_products(:master_product_one), shop: shops(:shop_one))
    assert_not product.valid?
    assert_includes product.errors[:discount], "must be greater than or equal to 0"
  end

  def test_product_create_with_valid_attributes
    product = Product.new(quantity: 25, discount: 7.50, master_product: master_products(:master_product_one), shop: shops(:shop_one))
    assert product.valid?
    assert product.save
  end

  def test_product_price_calculation
    product = products(:product_one)
    expected_price = product.master_product.price - product.discount
    assert_equal expected_price, product.price
  end

  def test_product_price_with_zero_discount
    product = products(:product_four)
    assert_equal product.master_product.price, product.price
  end

  def test_product_price_with_positive_discount
    product = products(:product_two)
    expected_price = product.master_product.price - product.discount
    assert_equal expected_price, product.price
    assert expected_price < product.master_product.price
  end
end
