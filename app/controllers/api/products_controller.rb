require "bigdecimal"

module Api
  class ProductsController < ApplicationController
    before_action :set_product, only: %i[show update destroy]

    def index
      products = Product.includes(:category)
      products = apply_filters(products)

      render json: {
        data: products.order(:id).map(&:as_api_json),
        filters: accepted_filters
      }
    end

    def show
      render json: { data: @product.as_api_json }
    end

    def create
      product = Product.create!(product_params)
      render json: { data: product.as_api_json }, status: :created
    end

    def update
      @product.update!(product_params)
      render json: { data: @product.as_api_json }
    end

    def destroy
      @product.destroy!
      head :no_content
    end

    private

    def set_product
      @product = Product.includes(:category).find(params[:id])
    end

    def product_params
      source = params[:product].present? ? params.require(:product) : params
      source.permit(:name, :description, :price, :stock, :category_id)
    end

    def apply_filters(products)
      products = products.search(params[:q].presence || params[:search])
      products = products.by_category(integer_param(:category_id))

      min_price = decimal_param(:min_price)
      max_price = decimal_param(:max_price)
      if min_price && max_price && min_price > max_price
        raise ActionController::BadRequest, "min_price no puede ser mayor que max_price"
      end

      products = products.where("products.price >= ?", min_price) if min_price
      products = products.where("products.price <= ?", max_price) if max_price

      case params[:in_stock].to_s.downcase
      when "", nil
        products
      when "true", "1", "yes", "si"
        products.where("products.stock > 0")
      when "false", "0", "no"
        products.where(stock: 0)
      else
        raise ActionController::BadRequest, "in_stock debe ser true o false"
      end
    end

    def decimal_param(name)
      return nil if params[name].blank?

      BigDecimal(params[name].to_s)
    rescue ArgumentError
      raise ActionController::BadRequest, "#{name} debe ser un numero decimal valido"
    end

    def integer_param(name)
      return nil if params[name].blank?

      value = Integer(params[name].to_s, 10)
      return value if value.positive?

      raise ActionController::BadRequest, "#{name} debe ser un entero positivo"
    rescue ArgumentError
      raise ActionController::BadRequest, "#{name} debe ser un entero valido"
    end

    def accepted_filters
      {
        q: params[:q].presence,
        search: params[:search].presence,
        category_id: params[:category_id].presence,
        min_price: params[:min_price].presence,
        max_price: params[:max_price].presence,
        in_stock: params[:in_stock].presence
      }.compact
    end
  end
end
