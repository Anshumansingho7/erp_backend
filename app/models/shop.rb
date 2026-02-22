class Shop < ApplicationRecord
  belongs_to :company
  has_many :products, dependent: :destroy
  has_many :orders, dependent: :destroy

  validates :name, presence: true
  validates :phone, presence: true
end
