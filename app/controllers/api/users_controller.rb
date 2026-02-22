class Api::UsersController < ApplicationController
  def create
    user = current_user.company.users.new(user_params)

    if user.save
      render json: { message: "User created", user: user }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
