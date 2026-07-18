require "test_helper"

class JsonWebTokenTest < ActiveSupport::TestCase
  test "genera y decodifica un token correctamente" do
    token = JsonWebToken.encode(25)
    payload = JsonWebToken.decode(token)

    assert token.present?
    assert_equal 25, payload[:user_id]
    assert payload[:iat].present?
    assert payload[:exp].present?
    assert payload[:exp] > Time.current.to_i
  end

  test "rechaza un token invalido" do
    assert_raises JWT::DecodeError do
      JsonWebToken.decode("token-invalido")
    end
  end

  test "rechaza un token expirado" do
    expired_token = JWT.encode(
      {
        user_id: 1,
        exp: 1.minute.ago.to_i
      },
      ENV.fetch("JWT_SECRET"),
      "HS256"
    )

    assert_raises JWT::ExpiredSignature do
      JsonWebToken.decode(expired_token)
    end
  end
end