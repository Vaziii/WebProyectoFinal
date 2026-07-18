module Api
  class UsersController < ApplicationController
    wrap_parameters false

    before_action :authenticate_request, only: %i[show update destroy]
    before_action :set_user, only: %i[show update destroy]
    before_action :authorize_owner, only: %i[show update destroy]

    def register
      user = User.create!(user_params)

      render json: {
        message: "Usuario registrado correctamente",
        data: UserSerializer.render(user)
      }, status: :created
    end

    def show
      render json: {
        data: UserSerializer.render(@user)
      }, status: :ok
    end

    def update
      @user.update!(user_params)

      render json: {
        message: "Usuario actualizado correctamente",
        data: UserSerializer.render(@user)
      }, status: :ok
    end

    def destroy
      @user.destroy!

      head :no_content
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def authorize_owner
      return if current_user.id == @user.id

      render_error(
        :forbidden,
        "Acceso denegado",
        "No puedes consultar o modificar la cuenta de otro usuario"
      )
    end

    def user_params
      source =
        if params[:user].is_a?(ActionController::Parameters)
          params.require(:user)
        else
          params
        end

      permitted = source.permit(
        :first_name,
        :last_name,
        :email,
        :password,
        :password_confirmation,
        :address,
        :phone_number,
        :firstName,
        :lastName,
        :passwordConfirmation,
        :phoneNumber
      )

      {
        first_name: permitted[:first_name].presence || permitted[:firstName],
        last_name: permitted[:last_name].presence || permitted[:lastName],
        email: permitted[:email],
        password: permitted[:password],
        password_confirmation: permitted[:password_confirmation].presence ||
                               permitted[:passwordConfirmation],
        address: permitted[:address],
        phone_number: permitted[:phone_number].presence ||
                      permitted[:phoneNumber]
      }.compact
    end
  end
end