class Product < ApplicationRecord
  belongs_to :category, optional: true

  before_validation :normalize_name

  validates :name, presence: true, length: { maximum: 120 }
  validates :description, length: { maximum: 1_000 }, allow_blank: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :category_must_exist

  scope :by_category, ->(category_id) { category_id.present? ? where(category_id: category_id) : all }
  scope :search, lambda { |term|
    if term.present?
      sanitized = sanitize_sql_like(term.to_s.downcase.strip)
      where(
        "LOWER(products.name) LIKE :term OR LOWER(COALESCE(products.description, '')) LIKE :term",
        term: "%#{sanitized}%"
      )
    else
      all
    end
  }

  def as_api_json(include_category: true)
    payload = {
      id: id,
      name: name,
      description: description,
      price: price.to_s("F"),
      stock: stock,
      created_at: created_at,
      updated_at: updated_at
    }

    payload[:category] = category&.as_api_json if include_category
    payload
  end

  private

  def normalize_name
    self.name = name.to_s.strip.presence
  end

  def category_must_exist
    return if category_id.blank? || category.present?

    errors.add(:category_id, "no existe")
  end
end
