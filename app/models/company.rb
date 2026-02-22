class Company < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :master_products, dependent: :destroy
  has_many :shops, dependent: :destroy
  validates :name, presence: true, uniqueness: true
end
