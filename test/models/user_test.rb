require "test_helper"

class UserTest < ActiveSupport::TestCase
  def valid_attributes
    {
      first_name: "Ana",
      last_name: "Perez",
      email: "ana.prueba@correo.com",
      password: "Clave123*",
      password_confirmation: "Clave123*",
      address: "Quito",
      phone_number: "0991234567"
    }
  end

  test "crea un usuario con datos validos" do
    user = User.new(valid_attributes)

    assert user.valid?
    assert user.save
  end

  test "normaliza el correo en minusculas" do
    user = User.create!(
      valid_attributes.merge(email: "ANA.PRUEBA@CORREO.COM")
    )

    assert_equal "ana.prueba@correo.com", user.email
  end

  test "cifra la contraseña con bcrypt" do
    user = User.create!(valid_attributes)

    assert_not_equal "Clave123*", user.password_digest
    assert user.password_digest.start_with?("$2")
    assert user.authenticate("Clave123*")
    assert_not user.authenticate("Incorrecta123")
  end

  test "rechaza nombres vacios" do
    user = User.new(
      valid_attributes.merge(
        first_name: "",
        last_name: ""
      )
    )

    assert_not user.valid?
    assert user.errors[:first_name].any?
    assert user.errors[:last_name].any?
  end

  test "rechaza correo con formato invalido" do
    user = User.new(
      valid_attributes.merge(email: "correo-invalido")
    )

    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "rechaza correo duplicado sin importar mayusculas" do
    User.create!(valid_attributes)

    duplicate = User.new(
      valid_attributes.merge(
        email: "ANA.PRUEBA@CORREO.COM",
        phone_number: "0981111111"
      )
    )

    assert_not duplicate.valid?
    assert duplicate.errors[:email].any?
  end

  test "rechaza contraseña menor a ocho caracteres" do
    user = User.new(
      valid_attributes.merge(
        password: "Abc123",
        password_confirmation: "Abc123"
      )
    )

    assert_not user.valid?
    assert user.errors[:password].any?
  end

  test "rechaza confirmacion de contraseña diferente" do
    user = User.new(
      valid_attributes.merge(
        password_confirmation: "OtraClave123*"
      )
    )

    assert_not user.valid?
    assert user.errors[:password_confirmation].any?
  end

  test "rechaza telefono con letras" do
    user = User.new(
      valid_attributes.merge(phone_number: "09ABC123")
    )

    assert_not user.valid?
    assert user.errors[:phone_number].any?
  end
end