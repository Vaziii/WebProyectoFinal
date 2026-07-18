require "test_helper"

class UsersAuthFlowTest < ActionDispatch::IntegrationTest
  setup do
    @password = "Clave123*"

    @user = User.create!(
      first_name: "Ana",
      last_name: "Perez",
      email: "ana.integration@correo.com",
      password: @password,
      password_confirmation: @password,
      address: "Quito",
      phone_number: "0991234567"
    )
  end

  test "registra un usuario correctamente" do
    assert_difference("User.count", 1) do
      post "/api/users/register",
           params: {
             firstName: "Carlos",
             lastName: "Lopez",
             email: "carlos@correo.com",
             password: "Carlos123*",
             passwordConfirmation: "Carlos123*",
             address: "Cuenca",
             phoneNumber: "0987654321"
           },
           as: :json
    end

    assert_response :created

    body = response_json

    assert_equal "Usuario registrado correctamente", body["message"]
    assert_equal "Carlos", body.dig("data", "firstName")
    assert_equal "carlos@correo.com", body.dig("data", "email")

    assert_nil body.dig("data", "password")
    assert_nil body.dig("data", "passwordDigest")
    assert_not_includes response.body, "password_digest"
  end

  test "rechaza un correo duplicado" do
    post "/api/users/register",
         params: {
           firstName: "Otra",
           lastName: "Persona",
           email: "ANA.INTEGRATION@CORREO.COM",
           password: "OtraClave123*",
           passwordConfirmation: "OtraClave123*"
         },
         as: :json

    assert_response :unprocessable_content

    body = response_json
    assert_equal "Datos inválidos", body.dig("error", "message")
  end

  test "inicia sesion y devuelve un token" do
    post "/api/users/login",
         params: {
           email: @user.email,
           password: @password
         },
         as: :json

    assert_response :success

    body = response_json

    assert_equal "Inicio de sesión correcto", body["message"]
    assert body["token"].present?
    assert_equal @user.id, body.dig("user", "userId")
    assert_nil body.dig("user", "passwordDigest")
  end

  test "rechaza contraseña incorrecta" do
    post "/api/users/login",
         params: {
           email: @user.email,
           password: "ContraseñaIncorrecta"
         },
         as: :json

    assert_response :unauthorized

    body = response_json
    assert_equal "Credenciales inválidas", body.dig("error", "message")
  end

  test "consulta su propio perfil con token valido" do
    get "/api/users/#{@user.id}",
        headers: authorization_headers(@user),
        as: :json

    assert_response :success

    body = response_json

    assert_equal @user.id, body.dig("data", "userId")
    assert_equal @user.email, body.dig("data", "email")
    assert_not_includes response.body, "password_digest"
  end

  test "rechaza consulta sin token" do
    get "/api/users/#{@user.id}", as: :json

    assert_response :unauthorized

    body = response_json
    assert_equal "No autorizado", body.dig("error", "message")
  end

  test "rechaza un token invalido" do
    get "/api/users/#{@user.id}",
        headers: {
          "Authorization" => "Bearer token-invalido"
        },
        as: :json

    assert_response :unauthorized

    body = response_json
    assert_equal "El token es inválido", body.dig("error", "details")
  end

  test "impide consultar la cuenta de otro usuario" do
    other_user = User.create!(
      first_name: "Elkin",
      last_name: "Prueba",
      email: "elkin.prueba@correo.com",
      password: "Elkin123*",
      password_confirmation: "Elkin123*"
    )

    get "/api/users/#{other_user.id}",
        headers: authorization_headers(@user),
        as: :json

    assert_response :forbidden

    body = response_json
    assert_equal "Acceso denegado", body.dig("error", "message")
  end

  test "actualiza su propia cuenta" do
    put "/api/users/#{@user.id}",
        params: {
          firstName: "Ana Maria",
          address: "Quito norte",
          phoneNumber: "0988888888"
        },
        headers: authorization_headers(@user),
        as: :json

    assert_response :success

    body = response_json

    assert_equal "Usuario actualizado correctamente", body["message"]
    assert_equal "Ana Maria", body.dig("data", "firstName")
    assert_equal "Quito norte", body.dig("data", "address")

    @user.reload

    assert_equal "Ana Maria", @user.first_name
    assert_equal "Quito norte", @user.address
  end

  test "elimina su propia cuenta" do
    assert_difference("User.count", -1) do
      delete "/api/users/#{@user.id}",
             headers: authorization_headers(@user),
             as: :json
    end

    assert_response :no_content
    assert_not User.exists?(@user.id)
  end

  private

  def authorization_headers(user)
    {
      "Authorization" => "Bearer #{JsonWebToken.encode(user.id)}"
    }
  end

  def response_json
    JSON.parse(response.body)
  end
end