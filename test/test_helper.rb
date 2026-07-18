ENV["RAILS_ENV"] ||= "test"

# Clave exclusiva para pruebas automatizadas.
# No se utiliza en desarrollo ni producción.
ENV["JWT_SECRET"] ||= "test-jwt-secret-key-grupo-7-ecommerce-2026"

require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Evita inconvenientes de procesos paralelos en Windows.
    parallelize(workers: 1)

    fixtures :all
  end
end