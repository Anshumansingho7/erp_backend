require "test_helper"

class CompanyTest < ActiveSupport::TestCase
  def test_company_has_many_users
    company = companies(:company_one)
    assert_kind_of ActiveRecord::Associations::CollectionProxy, company.users
  end

  def test_company_has_many_master_products
    company = companies(:company_one)
    assert_kind_of ActiveRecord::Associations::CollectionProxy, company.master_products
  end

  def test_company_has_many_shops
    company = companies(:company_one)
    assert_kind_of ActiveRecord::Associations::CollectionProxy, company.shops
  end

  def test_company_name_presence
    company = Company.new
    assert_not company.valid?
    assert_includes company.errors[:name], "can't be blank"
  end

  def test_company_name_uniqueness
    company1 = companies(:company_one)
    company2 = Company.new(name: company1.name)
    assert_not company2.valid?
    assert_includes company2.errors[:name], "has already been taken"
  end

  def test_company_create_with_valid_attributes
    company = Company.new(name: "New Company")
    assert company.valid?
    assert company.save
  end

  def test_company_destroy_destroys_associated_users
    company = Company.create(name: "Test Company Delete")
    user = company.users.create(email: "test@example.com", password: "password123")
    user_id = user.id
    company.destroy
    assert_not User.exists?(user_id)
  end

  def test_company_destroy_destroys_associated_master_products
    company = Company.create(name: "Test Company Delete 2")
    master_product = company.master_products.create(name: "Test Product", sku: "TEST_SKU_#{Time.now.to_i}", price: 100.00)
    master_product_id = master_product.id
    company.destroy
    assert_not MasterProduct.exists?(master_product_id)
  end

  def test_company_destroy_destroys_associated_shops
    company = Company.create(name: "Test Company Delete 3")
    shop = company.shops.create(name: "Test Shop", phone: "1234567890")
    shop_id = shop.id
    company.destroy
    assert_not Shop.exists?(shop_id)
  end
end
