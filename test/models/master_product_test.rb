require "test_helper"

class MasterProductTest < ActiveSupport::TestCase
  def test_master_product_belongs_to_company
    master_product = master_products(:master_product_one)
    assert_instance_of Company, master_product.company
  end

  def test_master_product_has_many_products
    master_product = master_products(:master_product_one)
    assert_kind_of ActiveRecord::Associations::CollectionProxy, master_product.products
  end

  def test_master_product_name_presence
    master_product = MasterProduct.new(sku: "SKU123", price: 100.00, company: companies(:company_one))
    assert_not master_product.valid?
    assert_includes master_product.errors[:name], "can't be blank"
  end

  def test_master_product_sku_presence
    master_product = MasterProduct.new(name: "Product", price: 100.00, company: companies(:company_one))
    assert_not master_product.valid?
    assert_includes master_product.errors[:sku], "can't be blank"
  end

  def test_master_product_sku_uniqueness
    master_product1 = master_products(:master_product_one)
    master_product2 = MasterProduct.new(name: "Product", sku: master_product1.sku, price: 100.00, company: companies(:company_one))
    assert_not master_product2.valid?
    assert_includes master_product2.errors[:sku], "has already been taken"
  end

  def test_master_product_price_presence
    master_product = MasterProduct.new(name: "Product", sku: "SKU123", company: companies(:company_one))
    assert_not master_product.valid?
    assert_includes master_product.errors[:price], "can't be blank"
  end

  def test_master_product_create_with_valid_attributes
    master_product = MasterProduct.new(name: "New Product", sku: "SKU999", price: 150.00, company: companies(:company_one))
    assert master_product.valid?
    assert master_product.save
  end

  def test_master_product_destroy_destroys_associated_products
    # Create a new master product with a product to avoid foreign key constraints
    master_product = MasterProduct.create(name: "Test Product", sku: "TEST_SKU_#{Time.now.to_i}", price: 100.00, company: companies(:company_one))
    product = master_product.products.create(quantity: 5, discount: 0, shop: shops(:shop_three))
    product_id = product.id
    master_product.destroy
    assert_not Product.exists?(product_id)
  end

  def test_master_product_price_numeric
    master_product = MasterProduct.new(name: "Product", sku: "SKU123", price: 100.50, company: companies(:company_one))
    assert master_product.valid?
  end
end
