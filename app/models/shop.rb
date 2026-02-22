class Shop < ApplicationRecord
  belongs_to :company

  validates :name, presence: true
  validates :phone, presence: true
end
