module Receipts
  class CreateService
    def initialize(user:, items:)
      @user = user
      @items = items
    end

    def call
      normalized_items = normalize_items

      if normalized_items.empty?
        raise BusinessRuleError.new(
          "Datos inválidos",
          {
            items: [
              "Debe incluir al menos un producto"
            ]
          }
        )
      end

      Receipt.transaction do
        create_receipt(normalized_items)
      end
    end

    private

    def create_receipt(normalized_items)
      product_ids = normalized_items.map do |item|
        item[:product_id]
      end

      products = Product
                 .lock
                 .where(id: product_ids)
                 .index_by(&:id)

      validate_existing_products!(
        product_ids,
        products
      )

      amount_of_items = normalized_items.sum do |item|
        item[:quantity]
      end

      receipt = @user.receipts.create!(
        total: BigDecimal("0"),
        amount_of_items: amount_of_items
      )

      total = BigDecimal("0")

      normalized_items.each do |item|
        product = products.fetch(
          item[:product_id]
        )

        quantity = item[:quantity]

        validate_stock!(
          product,
          quantity
        )

        unit_price = product.price
        subtotal = unit_price * quantity

        receipt.receipt_items.create!(
          product: product,
          quantity: quantity,
          unit_price: unit_price,
          subtotal: subtotal
        )

        product.update!(
          stock: product.stock - quantity
        )

        total += subtotal
      end

      receipt.update!(
        total: total
      )

      Receipt
        .includes(receipt_items: :product)
        .find(receipt.id)
    end

    def normalize_items
      grouped_items = Hash.new(0)

      Array(@items).each_with_index do |raw_item, index|
        item = normalize_hash(
          raw_item,
          index
        )

        product_id = positive_integer(
          item["productId"] ||
          item["product_id"]
        )

        quantity = positive_integer(
          item["quantity"]
        )

        unless product_id
          raise BusinessRuleError.new(
            "Datos inválidos",
            {
              "items[#{index}].productId": [
                "Debe ser un número entero mayor que 0"
              ]
            }
          )
        end

        unless quantity
          raise BusinessRuleError.new(
            "Datos inválidos",
            {
              "items[#{index}].quantity": [
                "Debe ser un número entero mayor que 0"
              ]
            }
          )
        end

        grouped_items[product_id] += quantity
      end

      grouped_items.map do |product_id, quantity|
        {
          product_id: product_id,
          quantity: quantity
        }
      end
    end

    def normalize_hash(raw_item, index)
      unless raw_item.respond_to?(:to_h)
        raise BusinessRuleError.new(
          "Datos inválidos",
          {
            "items[#{index}]": [
              "Debe ser un objeto JSON válido"
            ]
          }
        )
      end

      hash =
        if raw_item.respond_to?(:to_unsafe_h)
          raw_item.to_unsafe_h
        else
          raw_item.to_h
        end

      hash.stringify_keys
    end

    def positive_integer(value)
      value_as_text = value.to_s

      return nil unless value_as_text.match?(
        /\A[1-9]\d*\z/
      )

      value_as_text.to_i
    end

    def validate_existing_products!(
      product_ids,
      products
    )
      missing_ids = product_ids.uniq -
                    products.keys

      return if missing_ids.empty?

      raise BusinessRuleError.new(
        "Producto no encontrado",
        {
          productIds: missing_ids
        }
      )
    end

    def validate_stock!(product, quantity)
      return if product.stock >= quantity

      raise BusinessRuleError.new(
        "Stock insuficiente",
        {
          productId: product.id,
          productName: product.name,
          requestedQuantity: quantity,
          availableStock: product.stock
        }
      )
    end
  end
end