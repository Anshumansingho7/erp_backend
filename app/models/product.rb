class Product < ApplicationRecord
  belongs_to :master_product
  belongs_to :shop

  validates :quantity, presence: true
  validates :discount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def price
    master_product.price - discount
  end
end
