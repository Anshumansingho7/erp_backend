class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 1 }
  validates :price, presence: true
  validates :discount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :set_price_from_product

  private

  def set_price_from_product
    return unless product.present?

    self.price = product.price * quantity - discount
  end
end
