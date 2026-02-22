class Order < ApplicationRecord
  belongs_to :shop

  has_many :order_items, dependent: :destroy
  accepts_nested_attributes_for :order_items

  validates :total_amount, presence: true
  validates :customer_name, presence: true
  validates :customer_phone, presence: true
  before_save :calculate_total

  private

  def calculate_total
    self.total_amount = order_items.sum(:price)
  end
end
