class Enrolment < ApplicationRecord

  def present
    "#{name}"
  end
end