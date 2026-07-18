class User < ApplicationRecord
  has_secure_password

  before_validation :normalize_fields

  validates :first_name,
            presence: true,
            length: { maximum: 80 }

  validates :last_name,
            presence: true,
            length: { maximum: 80 }

  validates :email,
            presence: true,
            length: { maximum: 255 },
            format: {
              with: URI::MailTo::EMAIL_REGEXP,
              message: "no tiene un formato válido"
            },
            uniqueness: {
              case_sensitive: false,
              message: "ya está registrado"
            }

  validates :password,
            length: {
              minimum: 8,
              message: "debe tener al menos 8 caracteres"
            },
            allow_nil: true

  validates :address,
            length: { maximum: 255 },
            allow_blank: true

  validates :phone_number,
            format: {
              with: /\A\+?[0-9]{7,15}\z/,
              message: "debe contener entre 7 y 15 dígitos"
            },
            allow_blank: true

  private

  def normalize_fields
    self.first_name = first_name.to_s.strip.presence
    self.last_name = last_name.to_s.strip.presence
    self.email = email.to_s.strip.downcase.presence
    self.address = address.to_s.strip.presence
    self.phone_number = phone_number.to_s.strip.presence
  end
end