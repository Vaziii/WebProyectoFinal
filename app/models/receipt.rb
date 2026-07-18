class Receipt < ApplicationRecord
  belongs_to :user

  has_many :receipt_items,
           dependent: :destroy,
           inverse_of: :receipt

  validates :total,
            presence: true,
            numericality: {
              greater_than_or_equal_to: 0
            }

  validates :amount_of_items,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 0
            }
end