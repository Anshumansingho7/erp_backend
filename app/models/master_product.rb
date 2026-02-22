class MasterProduct < ApplicationRecord
  belongs_to :company
  has_many :products, dependent: :destroy

  validates :name, presence: true
  validates :sku, presence: true, uniqueness: true
  validates :price, presence: true
end
