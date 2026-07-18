module Receipts
  class DeleteService
    def initialize(receipt:)
      @receipt = receipt
    end

    def call
      Receipt.transaction do
        restore_stock
        @receipt.destroy!
      end
    end

    private

    def restore_stock
      items = @receipt.receipt_items.to_a

      product_ids = items
                    .map(&:product_id)
                    .uniq

      products = Product
                 .lock
                 .where(id: product_ids)
                 .order(:id)
                 .index_by(&:id)

      items.each do |item|
        product = products.fetch(
          item.product_id
        )

        product.update!(
          stock: product.stock + item.quantity
        )
      end
    end
  end
end