require "test_helper"

class ReceiptTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      first_name: "Scar",
      last_name: "Recibos",
      email: "scar.receipt.model@correo.com",
      password: "Clave123*",
      password_confirmation: "Clave123*"
    )
  end

  test "es válido con usuario total y cantidad de productos" do
    receipt = Receipt.new(
      user: @user,
      total: BigDecimal("25.50"),
      amount_of_items: 2
    )

    assert receipt.valid?
  end

  test "requiere un usuario" do
    receipt = Receipt.new(
      total: BigDecimal("25.50"),
      amount_of_items: 2
    )

    assert_not receipt.valid?
    assert receipt.errors[:user].present?
  end

  test "rechaza una cantidad de productos igual a cero" do
    receipt = Receipt.new(
      user: @user,
      total: BigDecimal("0"),
      amount_of_items: 0
    )

    assert_not receipt.valid?
    assert receipt.errors[:amount_of_items].present?
  end

  test "rechaza un total negativo" do
    receipt = Receipt.new(
      user: @user,
      total: BigDecimal("-1.00"),
      amount_of_items: 1
    )

    assert_not receipt.valid?
    assert receipt.errors[:total].present?
  end
end