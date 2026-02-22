class ApplicationController < ActionController::API
  include Devise::Controllers::Helpers
  before_action :authenticate_user!

  private

  def authenticate_user!
    render json: { error: "Please log in first." }, status: :unauthorized unless current_user
  end
end