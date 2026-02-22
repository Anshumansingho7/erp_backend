class SessionsController < Devise::SessionsController
  respond_to :json

  private

  def respond_with(resource, options = {})
    if resource.persisted?
      render json: {
        status: { code: 200, message: "Logged in successfully." },
        data: current_user
      }, status: :ok
    else
      render json: {
        status: { code: 422, message: "Login failed." }
      }, status: :unprocessable_entity
    end
  end

  def respond_to_on_destroy(_resource)
    if request.headers["Authorization"].present?
      jwt_token = request.headers["Authorization"].split(" ").last

      begin
        jwt_payload = JWT.decode(jwt_token, Rails.application.credentials.secret_key_base).first
        user = User.find(jwt_payload["sub"])

        sign_out(user)

        render json: {
          status: 200,
          message: "Logged out successfully"
        }, status: :ok

      rescue JWT::DecodeError
        render json: { error: "Invalid token" }, status: :unauthorized
      end
    else
      render json: { error: "Authorization header missing" }, status: :unauthorized
    end
  end
end
