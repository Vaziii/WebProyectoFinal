class Category < ApplicationRecord
  has_many :products, dependent: :nullify

  before_validation :normalize_name

  validates :name, presence: true, length: { maximum: 80 }, uniqueness: { case_sensitive: false }
  validates :description, length: { maximum: 500 }, allow_blank: true

  def as_api_json(include_products: false)
    payload = {
      id: id,
      name: name,
      description: description,
      created_at: created_at,
      updated_at: updated_at
    }

    if include_products
      payload[:products] = products.order(:id).map { |product| product.as_api_json(include_category: false) }
    end

    payload
  end

  private

  def normalize_name
    self.name = name.to_s.strip.presence
  end
end
