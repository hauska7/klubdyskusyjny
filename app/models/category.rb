class Category < ApplicationRecord
  has_many :categorizations
  has_many :topics, through: :categorizations

  def present
    name
  end
end