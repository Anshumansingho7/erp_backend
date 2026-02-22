# This file seeds the database with sample data for development and testing
# Run with: bin/rails db:seed

require 'csv'

puts "🌱 Starting database seed..."

# Create Companies
puts "📦 Creating companies..."
company1 = Company.find_or_create_by!(name: "TechCorp India")
company2 = Company.find_or_create_by!(name: "RetailHub Solutions")

puts "✓ Created #{Company.count} companies"

# Create Users for Companies
puts "👥 Creating users..."
user1 = User.find_or_initialize_by(email: "admin@techcorp.com")
if user1.new_record?
  user1.password = "password123"
  user1.password_confirmation = "password123"
  user1.company = company1
  user1.save!
end

user2 = User.find_or_initialize_by(email: "manager@techcorp.com")
if user2.new_record?
  user2.password = "password123"
  user2.password_confirmation = "password123"
  user2.company = company1
  user2.save!
end

user3 = User.find_or_initialize_by(email: "admin@retailhub.com")
if user3.new_record?
  user3.password = "password123"
  user3.password_confirmation = "password123"
  user3.company = company2
  user3.save!
end

puts "✓ Created #{User.count} users"

# Create Master Products for Companies
puts "📚 Creating master products..."

master_products_data = [
  { sku: "TECH-001", name: "Laptop Pro 15", price: 85000.00 },
  { sku: "TECH-002", name: "Wireless Mouse", price: 1200.00 },
  { sku: "TECH-003", name: "USB-C Hub", price: 3500.00 },
  { sku: "TECH-004", name: "Monitor 4K", price: 35000.00 },
  { sku: "TECH-005", name: "Keyboard Mechanical", price: 8000.00 }
]

master_products_data.each do |data|
  MasterProduct.find_or_create_by!(sku: data[:sku]) do |mp|
    mp.name = data[:name]
    mp.price = data[:price]
    mp.company = company1
  end
end

retail_products_data = [
  { sku: "RETAIL-001", name: "Cotton T-Shirt", price: 499.00 },
  { sku: "RETAIL-002", name: "Denim Jeans", price: 1299.00 },
  { sku: "RETAIL-003", name: "Leather Belt", price: 799.00 },
  { sku: "RETAIL-004", name: "Running Shoes", price: 2999.00 }
]

retail_products_data.each do |data|
  MasterProduct.find_or_create_by!(sku: data[:sku]) do |mp|
    mp.name = data[:name]
    mp.price = data[:price]
    mp.company = company2
  end
end

puts "✓ Created #{MasterProduct.count} master products"

# Create Shops
puts "🏪 Creating shops..."

shop1 = Shop.find_or_initialize_by(name: "TechCorp - Delhi")
if shop1.new_record?
  shop1.phone = "9876543210"
  shop1.company = company1
  shop1.save!
end

shop2 = Shop.find_or_initialize_by(name: "TechCorp - Mumbai")
if shop2.new_record?
  shop2.phone = "9123456789"
  shop2.company = company1
  shop2.save!
end

shop3 = Shop.find_or_initialize_by(name: "RetailHub - Bangalore")
if shop3.new_record?
  shop3.phone = "8765432109"
  shop3.company = company2
  shop3.save!
end

puts "✓ Created #{Shop.count} shops"

# Create Shop Products (linking master products to shops)
puts "🛒 Linking products to shops..."

[ shop1, shop2 ].each do |shop|
  company1.master_products.each do |master_product|
    Product.find_or_create_by!(shop: shop, master_product: master_product) do |product|
      product.quantity = rand(5..50)
      product.discount = [ 0, 500.00, 1000.00, 2000.00 ].sample
    end
  end
end

company2.master_products.each do |master_product|
  Product.find_or_create_by!(shop: shop3, master_product: master_product) do |product|
    product.quantity = rand(10..100)
    product.discount = [ 0, 100.00, 200.00, 500.00 ].sample
  end
end

puts "✓ Created #{Product.count} shop products"

# Create Orders
puts "📋 Creating orders..."

orders_data = [
  { shop: shop1, customer_name: "Rajesh Kumar", customer_phone: "9876543210", total_amount: 95000.00 },
  { shop: shop1, customer_name: "Priya Singh", customer_phone: "9123456780", total_amount: 12200.00 },
  { shop: shop2, customer_name: "Amit Patel", customer_phone: "8765432109", total_amount: 43500.00 },
  { shop: shop3, customer_name: "Neha Verma", customer_phone: "7654321098", total_amount: 7297.00 }
]

orders_data.each do |data|
  order = Order.find_or_initialize_by(shop: data[:shop], customer_name: data[:customer_name])
  unless order.persisted?
    order.customer_phone = data[:customer_phone]
    order.total_amount = data[:total_amount]
    order.save!
  end
end

puts "✓ Created #{Order.count} orders"

# Create Order Items
puts "📦 Creating order items..."

if shop1.orders.any?
  order = shop1.orders.first
  product = shop1.products.first
  if product
    OrderItem.find_or_create_by!(order: order, product: product) do |oi|
      oi.quantity = 1
      oi.price = product.master_product.price - (product.discount || 0)
      oi.discount = product.discount || 0
    end
  end
end

puts "✓ Created #{OrderItem.count} order items"

puts "\n✅ Database seed completed successfully!"
puts "\n📊 Summary:"
puts "   Companies: #{Company.count}"
puts "   Users: #{User.count}"
puts "   Master Products: #{MasterProduct.count}"
puts "   Shops: #{Shop.count}"
puts "   Shop Products: #{Product.count}"
puts "   Orders: #{Order.count}"
puts "   Order Items: #{OrderItem.count}"

puts "\n💡 Test Credentials:"
puts "   Email: admin@techcorp.com"
puts "   Password: password123"
