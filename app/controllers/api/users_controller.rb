module Api
  class UsersController < ApplicationController
    wrap_parameters false

    def register
      user = User.create!(user_params)

      render json: {
        message: "Usuario registrado correctamente",
        data: UserSerializer.render(user)
      }, status: :created
    end

    private

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
      }
    end
  end
end