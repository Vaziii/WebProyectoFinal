module Api
  class CategoriesController < ApplicationController
    before_action :authenticate_request, only: %i[create update destroy]
    before_action :require_admin, only: %i[create update destroy]
    before_action :set_category, only: %i[show update destroy]

    def index
      categories = Category.order(:name)
      render json: { data: categories.map(&:as_api_json) }
    end

    def show
      render json: { data: @category.as_api_json(include_products: true) }
    end

    def create
      category = Category.create!(category_params)
      render json: { data: category.as_api_json }, status: :created
    end

    def update
      @category.update!(category_params)
      render json: { data: @category.as_api_json }
    end

    def destroy
      @category.destroy!
      head :no_content
    end

    private

    def set_category
      @category = Category.includes(:products).find(params[:id])
    end

    def category_params
      source = params[:category].present? ? params.require(:category) : params
      source.permit(:name, :description)
    end
  end
end
