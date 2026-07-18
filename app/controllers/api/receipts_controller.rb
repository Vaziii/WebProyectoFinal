module Api
  class ReceiptsController < ApplicationController
    wrap_parameters false

    before_action :authenticate_request

    before_action :set_receipt,
                  only: %i[show destroy]

    before_action :authorize_receipt_owner,
                  only: %i[show destroy]

    def create
      receipt = Receipts::CreateService.new(
        user: current_user,
        items: receipt_items_params
      ).call

      render json: {
        message: "Recibo creado correctamente",
        data: ReceiptSerializer.call(receipt)
      }, status: :created
    end

    def index
      receipts = receipts_for_current_user

      render json: {
        data: receipts.map do |receipt|
          ReceiptSerializer.call(receipt)
        end
      }, status: :ok
    end

    def show
      render json: {
        data: ReceiptSerializer.call(@receipt)
      }, status: :ok
    end

    def by_user
      return unless authorize_requested_user

      receipts = receipts_for_current_user

      render json: {
        data: receipts.map do |receipt|
          ReceiptSerializer.call(receipt)
        end
      }, status: :ok
    end

    def destroy
      Receipts::DeleteService.new(
        receipt: @receipt
      ).call

      head :no_content
    end

    private

    def receipts_for_current_user
      current_user
        .receipts
        .includes(receipt_items: :product)
        .order(created_at: :desc)
    end

    def set_receipt
      @receipt = Receipt
                 .includes(receipt_items: :product)
                 .find(params[:id])
    end

    def authorize_receipt_owner
      return if @receipt.user_id == current_user.id

      render_error(
        :forbidden,
        "Acceso denegado",
        "No puedes consultar o eliminar el recibo de otro usuario"
      )
    end

    def authorize_requested_user
      return true if params[:user_id].to_i == current_user.id

      render_error(
        :forbidden,
        "Acceso denegado",
        "No puedes consultar los recibos de otro usuario"
      )

      false
    end

    def receipt_items_params
      source =
        if params[:receipt].is_a?(
          ActionController::Parameters
        )
          params.require(:receipt)
        else
          params
        end

      source.permit(
        items: [
          :productId,
          :product_id,
          :quantity
        ]
      )[:items]
    end
  end
end