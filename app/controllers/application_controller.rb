class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid
  rescue_from ActiveRecord::RecordNotDestroyed, with: :render_record_not_destroyed
  rescue_from ActionController::ParameterMissing, with: :render_bad_request
  rescue_from ActionController::BadRequest, with: :render_bad_request

  private

  def render_not_found(exception)
    render_error(:not_found, "Recurso no encontrado", exception.message)
  end

  def render_record_invalid(exception)
    render_error(:unprocessable_entity, "Datos invalidos", exception.record.errors.to_hash(true))
  end

  def render_record_not_destroyed(exception)
    render_error(:unprocessable_entity, "No se pudo eliminar el recurso", exception.record.errors.to_hash(true))
  end

  def render_bad_request(exception)
    render_error(:bad_request, "Solicitud invalida", exception.message)
  end

  def render_error(status, message, details = nil)
    body = { error: { message: message } }
    body[:error][:details] = details if details.present?
    render json: body, status: status
  end
end
