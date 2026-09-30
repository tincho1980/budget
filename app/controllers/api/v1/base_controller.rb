# Client portal API. It inherits from ActionController::API, not from
# ApplicationController, so it has no cookies, no session login and no CSRF:
# every request authenticates with the token issued by POST /api/v1/login.
class Api::V1::BaseController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_client!

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid
  rescue_from ActionController::ParameterMissing, with: :render_parameter_missing

  private

  attr_reader :current_user

  # Every query starts here, so a client can only ever reach its own data.
  def current_client
    current_user.client
  end

  # Reads "Authorization: Bearer <token>". Only portal users get API access.
  def authenticate_client!
    @current_user = authenticate_with_http_token do |token, _options|
      User.role_client.find_by(api_token: token)
    end

    render_error(:unauthorized, "Token inválido o ausente. Iniciá sesión con POST /api/v1/login.") unless @current_user
  end

  def render_error(status, message, details: nil)
    body = { error: { status: Rack::Utils.status_code(status), message: message, details: details }.compact }
    render json: body, status: status
  end

  # 404 also for other clients' records: the API never confirms they exist.
  def render_not_found
    render_error(:not_found, "Recurso no encontrado.")
  end

  def render_record_invalid(exception)
    render_error(:unprocessable_content, "No se pudo guardar.", details: exception.record.errors.full_messages)
  end

  def render_parameter_missing(exception)
    render_error(:bad_request, "Falta el parámetro '#{exception.param}'.")
  end
end
