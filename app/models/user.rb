class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  belongs_to :company
  validates :email, presence: true, uniqueness: true

  def jwt_payload
    { "foo" => "bar" }
  end
end
