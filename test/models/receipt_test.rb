require "test_helper"

class ReceiptItemTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      first_name: "Scar",
      last_name: "Detalle",
      email: "scar.item.model@correo.com",
      password: "Clave123*",
      password_confirmation: "Clave123*"
    )

    @product = Product.create!(
      name: "Producto para ReceiptItem",
      description: "Producto usado en pruebas.",
      price: BigDecimal("12.50"),
      stock: 10
    )

    @receipt = Receipt.create!(
      user: @user,
      total: BigDecimal("25.00"),
      amount_of_items: 2
    )
  end

  test "es válido con todos sus datos" do
    item = ReceiptItem.new(
      receipt: @receipt,
      product: @product,
      quantity: 2,
      unit_price: BigDecimal("12.50"),
      subtotal: BigDecimal("25.00")
    )

    assert item.valid?
  end

  test "rechaza cantidad igual a cero" do
    item = ReceiptItem.new(
      receipt: @receipt,
      product: @product,
      quantity: 0,
      unit_price: BigDecimal("12.50"),
      subtotal: BigDecimal("25.00")
    )

    assert_not item.valid?
    assert item.errors[:quantity].present?
  end

  test "rechaza precio unitario negativo" do
    item = ReceiptItem.new(
      receipt: @receipt,
      product: @product,
      quantity: 1,
      unit_price: BigDecimal("-1.00"),
      subtotal: BigDecimal("12.50")
    )

    assert_not item.valid?
    assert item.errors[:unit_price].present?
  end

  test "requiere recibo y producto" do
    item = ReceiptItem.new(
      quantity: 1,
      unit_price: BigDecimal("12.50"),
      subtotal: BigDecimal("12.50")
    )

    assert_not item.valid?
    assert item.errors[:receipt].present?
    assert item.errors[:product].present?
  end
end