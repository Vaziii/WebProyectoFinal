class JsonWebToken
  ALGORITHM = "HS256"
  EXPIRATION_TIME = 24.hours

  class << self
    def encode(user_id)
      payload = {
        user_id: user_id,
        iat: Time.current.to_i,
        exp: EXPIRATION_TIME.from_now.to_i
      }

      JWT.encode(payload, secret_key, ALGORITHM)
    end

    def decode(token)
      decoded = JWT.decode(
        token,
        secret_key,
        true,
        algorithm: ALGORITHM
      )

      decoded.first.with_indifferent_access
    end

    private

    def secret_key
      ENV.fetch("JWT_SECRET")
    end
  end
end