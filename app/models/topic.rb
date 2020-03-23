class Topic < ApplicationRecord
  has_many :categorizations
  has_many :categories, through: :categorizations

end