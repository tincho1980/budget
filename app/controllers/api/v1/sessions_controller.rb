class Api::V1::SessionsController < Api::V1::BaseController
  skip_before_action :authenticate_client!, only: :create
  rate_limit to: 10, within: 3.minutes, only: :create,
    with: -> { render_error(:too_many_requests, "Demasiados intentos. Probá de nuevo en unos minutos.") }

  # POST /api/v1/login  { "email_address": "...", "password": "..." }
  def create
    user = User.authenticate_by(email_address: params[:email_address].to_s, password: params[:password].to_s)

    # Same message for a wrong password and for team members, so the API
    # doesn't reveal which emails exist.
    if user&.role_client?
      user.regenerate_api_token
      @user = user
      render :create, status: :created
    else
      render_error(:unauthorized, "Email o contraseña incorrectos.")
    end
  end

  # DELETE /api/v1/logout — rotating the token invalidates the old one.
  def destroy
    current_user.regenerate_api_token
    head :no_content
  end
end
