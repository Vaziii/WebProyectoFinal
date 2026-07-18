require "test_helper"

class ReceiptsFlowTest < ActionDispatch::IntegrationTest
  setup do
    @password = "Clave123*"

    @user = User.create!(
      first_name: "Scar",
      last_name: "Compradora",
      email: "scar.receipts@correo.com",
      password: @password,
      password_confirmation: @password,
      address: "Quito",
      phone_number: "0991234567"
    )

    @other_user = User.create!(
      first_name: "Otro",
      last_name: "Usuario",
      email: "otro.receipts@correo.com",
      password: @password,
      password_confirmation: @password
    )

    @product_a = Product.create!(
      name: "Mouse inalámbrico de prueba",
      description: "Producto A para pruebas de recibos.",
      price: BigDecimal("10.50"),
      stock: 10
    )

    @product_b = Product.create!(
      name: "Teclado mecánico de prueba",
      description: "Producto B para pruebas de recibos.",
      price: BigDecimal("20.00"),
      stock: 5
    )
  end

  test "crea un recibo calcula el total y descuenta el stock" do
    assert_difference("Receipt.count", 1) do
      assert_difference("ReceiptItem.count", 2) do
        post "/api/receipts",
             params: {
               userId: @other_user.id,
               total: "0.01",
               items: [
                 {
                   productId: @product_a.id,
                   quantity: 2
                 },
                 {
                   productId: @product_b.id,
                   quantity: 1
                 }
               ]
             },
             headers: authorization_headers(@user),
             as: :json
      end
    end

    assert_response :created

    body = response_json

    assert_equal(
      "Recibo creado correctamente",
      body["message"]
    )

    assert_equal(
      @user.id,
      body.dig("data", "userId")
    )

    assert_equal(
      3,
      body.dig("data", "amountOfItems")
    )

    assert_equal(
      BigDecimal("41.00"),
      BigDecimal(body.dig("data", "total"))
    )

    receipt = Receipt.order(:id).last

    assert_equal @user.id, receipt.user_id
    assert_equal BigDecimal("41.00"), receipt.total
    assert_equal 3, receipt.amount_of_items

    assert_equal 8, @product_a.reload.stock
    assert_equal 4, @product_b.reload.stock
  end

  test "ignora el total enviado por el cliente" do
    post "/api/receipts",
         params: {
           total: "999999.99",
           items: [
             {
               productId: @product_a.id,
               quantity: 2
             }
           ]
         },
         headers: authorization_headers(@user),
         as: :json

    assert_response :created

    body = response_json

    assert_equal(
      BigDecimal("21.00"),
      BigDecimal(body.dig("data", "total"))
    )

    assert_equal(
      BigDecimal("21.00"),
      Receipt.order(:id).last.total
    )
  end

  test "rechaza una solicitud sin token" do
    post "/api/receipts",
         params: {
           items: [
             {
               productId: @product_a.id,
               quantity: 1
             }
           ]
         },
         as: :json

    assert_response :unauthorized

    body = response_json

    assert_equal(
      "No autorizado",
      body.dig("error", "message")
    )
  end

  test "rechaza un carrito vacío" do
    assert_no_difference("Receipt.count") do
      post "/api/receipts",
           params: {
             items: []
           },
           headers: authorization_headers(@user),
           as: :json
    end

    assert_response :unprocessable_content

    body = response_json

    assert_equal(
      "Datos inválidos",
      body.dig("error", "message")
    )
  end

  test "rechaza una cantidad igual a cero" do
    assert_no_difference("Receipt.count") do
      post "/api/receipts",
           params: {
             items: [
               {
                 productId: @product_a.id,
                 quantity: 0
               }
             ]
           },
           headers: authorization_headers(@user),
           as: :json
    end

    assert_response :unprocessable_content

    body = response_json

    assert_equal(
      "Datos inválidos",
      body.dig("error", "message")
    )
  end

  test "rechaza un producto inexistente" do
    nonexistent_id = Product.maximum(:id).to_i + 10_000

    assert_no_difference("Receipt.count") do
      post "/api/receipts",
           params: {
             items: [
               {
                 productId: nonexistent_id,
                 quantity: 1
               }
             ]
           },
           headers: authorization_headers(@user),
           as: :json
    end

    assert_response :unprocessable_content

    body = response_json

    assert_equal(
      "Producto no encontrado",
      body.dig("error", "message")
    )

    assert_includes(
      body.dig("error", "details", "productIds"),
      nonexistent_id
    )
  end

  test "rechaza stock insuficiente y no altera la base" do
    original_stock_a = @product_a.stock
    original_stock_b = @product_b.stock

    assert_no_difference("Receipt.count") do
      assert_no_difference("ReceiptItem.count") do
        post "/api/receipts",
             params: {
               items: [
                 {
                   productId: @product_a.id,
                   quantity: 2
                 },
                 {
                   productId: @product_b.id,
                   quantity: 100
                 }
               ]
             },
             headers: authorization_headers(@user),
             as: :json
      end
    end

    assert_response :unprocessable_content

    body = response_json

    assert_equal(
      "Stock insuficiente",
      body.dig("error", "message")
    )

    assert_equal(
      @product_b.id,
      body.dig("error", "details", "productId")
    )

    assert_equal original_stock_a, @product_a.reload.stock
    assert_equal original_stock_b, @product_b.reload.stock
  end

  test "lista solamente los recibos del usuario autenticado" do
    own_receipt = create_receipt_for(
      user: @user,
      items: [
        {
          productId: @product_a.id,
          quantity: 1
        }
      ]
    )

    other_receipt = create_receipt_for(
      user: @other_user,
      items: [
        {
          productId: @product_b.id,
          quantity: 1
        }
      ]
    )

    get "/api/receipts",
        headers: authorization_headers(@user),
        as: :json

    assert_response :success

    receipt_ids = response_json
                  .fetch("data")
                  .map do |receipt|
                    receipt.fetch("receiptId")
                  end

    assert_includes receipt_ids, own_receipt.id
    assert_not_includes receipt_ids, other_receipt.id
  end

  test "consulta su propio recibo" do
    receipt = create_receipt_for(
      user: @user,
      items: [
        {
          productId: @product_a.id,
          quantity: 1
        }
      ]
    )

    get "/api/receipts/#{receipt.id}",
        headers: authorization_headers(@user),
        as: :json

    assert_response :success

    body = response_json

    assert_equal(
      receipt.id,
      body.dig("data", "receiptId")
    )

    assert_equal(
      @user.id,
      body.dig("data", "userId")
    )
  end

  test "impide consultar el recibo de otro usuario" do
    receipt = create_receipt_for(
      user: @other_user,
      items: [
        {
          productId: @product_a.id,
          quantity: 1
        }
      ]
    )

    get "/api/receipts/#{receipt.id}",
        headers: authorization_headers(@user),
        as: :json

    assert_response :forbidden

    body = response_json

    assert_equal(
      "Acceso denegado",
      body.dig("error", "message")
    )
  end

  test "lista recibos mediante la ruta por usuario" do
    receipt = create_receipt_for(
      user: @user,
      items: [
        {
          productId: @product_a.id,
          quantity: 1
        }
      ]
    )

    get "/api/receipts/user/#{@user.id}",
        headers: authorization_headers(@user),
        as: :json

    assert_response :success

    receipt_ids = response_json
                  .fetch("data")
                  .map do |item|
                    item.fetch("receiptId")
                  end

    assert_includes receipt_ids, receipt.id
  end

  test "impide listar recibos de otro usuario" do
    get "/api/receipts/user/#{@other_user.id}",
        headers: authorization_headers(@user),
        as: :json

    assert_response :forbidden

    body = response_json

    assert_equal(
      "Acceso denegado",
      body.dig("error", "message")
    )
  end

  test "elimina un recibo propio y restaura el stock" do
    original_stock = @product_a.stock

    receipt = create_receipt_for(
      user: @user,
      items: [
        {
          productId: @product_a.id,
          quantity: 2
        }
      ]
    )

    assert_equal(
      original_stock - 2,
      @product_a.reload.stock
    )

    assert_difference("Receipt.count", -1) do
      assert_difference("ReceiptItem.count", -1) do
        delete "/api/receipts/#{receipt.id}",
               headers: authorization_headers(@user),
               as: :json
      end
    end

    assert_response :no_content
    assert_equal "", response.body
    assert_equal original_stock, @product_a.reload.stock
  end

  test "impide eliminar el recibo de otro usuario" do
    receipt = create_receipt_for(
      user: @other_user,
      items: [
        {
          productId: @product_a.id,
          quantity: 1
        }
      ]
    )

    assert_no_difference("Receipt.count") do
      delete "/api/receipts/#{receipt.id}",
             headers: authorization_headers(@user),
             as: :json
    end

    assert_response :forbidden
    assert Receipt.exists?(receipt.id)
  end

  private

  def create_receipt_for(user:, items:)
    Receipts::CreateService.new(
      user: user,
      items: items
    ).call
  end

  def authorization_headers(user)
    {
      "Authorization" =>
        "Bearer #{JsonWebToken.encode(user.id)}"
    }
  end

  def response_json
    JSON.parse(response.body)
  end
end