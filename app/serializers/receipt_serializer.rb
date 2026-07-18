class ReceiptSerializer
  def self.call(receipt)
    {
      receiptId: receipt.id,
      userId: receipt.user_id,
      total: money(receipt.total),
      amountOfItems: receipt.amount_of_items,
      items: receipt.receipt_items.map do |item|
        serialize_item(item)
      end,
      createdAt: receipt.created_at,
      updatedAt: receipt.updated_at
    }
  end

  def self.serialize_item(item)
    {
      receiptItemId: item.id,
      productId: item.product_id,
      productName: item.product.name,
      quantity: item.quantity,
      unitPrice: money(item.unit_price),
      subtotal: money(item.subtotal)
    }
  end

  def self.money(value)
    value.to_d.to_s("F")
  end

  private_class_method :serialize_item,
                       :money
end