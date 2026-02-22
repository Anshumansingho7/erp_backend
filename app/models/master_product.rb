class MasterProduct < ApplicationRecord
  belongs_to :company

  validates :name, presence: true
  validates :sku, presence: true, uniqueness: true
  validates :price, presence: true
end
