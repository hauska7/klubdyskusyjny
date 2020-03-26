class Topic < ApplicationRecord
  has_many :categorizations
  has_many :categories, through: :categorizations

  def self.build
    new(content: {})
  end

  def add_content(lang, text)
    content[lang.to_s] = text
  end
end