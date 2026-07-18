module Api
  class AuthController < ApplicationController
    wrap_parameters false

    def login
      email = login_params[:email].to_s.strip.downcase
      password = login_params[:password].to_s

      user = User.find_by(email: email)

      unless user&.authenticate(password)
        return render json: {
          error: {
            message: "Credenciales inválidas",
            details: "El correo o la contraseña son incorrectos"
          }
        }, status: :unauthorized
      end

      token = JsonWebToken.encode(user.id)

      render json: {
        message: "Inicio de sesión correcto",
        token: token,
        user: UserSerializer.render(user)
      }, status: :ok
    end

    private

    def login_params
      source =
        if params[:user].is_a?(ActionController::Parameters)
          params.require(:user)
        else
          params
        end

      source.permit(:email, :password)
    end
  end
end