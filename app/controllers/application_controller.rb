class ApplicationController < ActionController::API
  attr_reader :current_user

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid
  rescue_from ActiveRecord::RecordNotDestroyed, with: :render_record_not_destroyed
  rescue_from ActionController::ParameterMissing, with: :render_bad_request
  rescue_from ActionController::BadRequest, with: :render_bad_request

  rescue_from BusinessRuleError,
            with: :render_business_rule_error

  
  private

  def authenticate_request
    token = bearer_token

    if token.blank?
      return render_error(
        :unauthorized,
        "No autorizado",
        "Debes enviar un token en el encabezado Authorization"
      )
    end

    payload = JsonWebToken.decode(token)
    @current_user = User.find(payload[:user_id])
  rescue JWT::ExpiredSignature
    render_error(
      :unauthorized,
      "No autorizado",
      "El token ha expirado"
    )
  rescue JWT::DecodeError
    render_error(
      :unauthorized,
      "No autorizado",
      "El token es inválido"
    )
  rescue KeyError
    render_error(
      :internal_server_error,
      "Error de configuración",
      "JWT_SECRET no está configurado"
    )
  rescue ActiveRecord::RecordNotFound
    render_error(
      :unauthorized,
      "No autorizado",
      "El usuario asociado al token no existe"
    )
  end

  def require_admin
    return if current_user&.admin?

    render_error(
      :forbidden,
      "Acceso denegado",
      "Solo un administrador puede realizar esta accion"
    )
  end

  def bearer_token
    scheme, token = request.headers["Authorization"].to_s.split(" ", 2)

    return token if scheme&.casecmp("Bearer")&.zero? && token.present?

    nil
  end

  def render_not_found(exception)
    render_error(
      :not_found,
      "Recurso no encontrado",
      exception.message
    )
  end

  def render_record_invalid(exception)
    render_error(
      :unprocessable_content,
      "Datos inválidos",
      exception.record.errors.to_hash(true)
    )
  end

  def render_record_not_destroyed(exception)
    render_error(
      :unprocessable_content,
      "No se pudo eliminar el recurso",
      exception.record.errors.to_hash(true)
    )
  end

  def render_bad_request(exception)
    render_error(
      :bad_request,
      "Solicitud inválida",
      exception.message
    )
  end

  def render_error(status, message, details = nil)
    body = {
      error: {
        message: message
      }
    }

    body[:error][:details] = details if details.present?

    render json: body, status: status
  end

  def render_business_rule_error(error)
    render json: {
      error: {
        message: error.message,
        details: error.details
      }
    }, status: :unprocessable_content
  end

end
