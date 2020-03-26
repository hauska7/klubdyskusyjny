class X
  def self.query(what, a = nil)
    case what
    when "categories"
      Category.all.to_a
    else fail
    end
  end
end