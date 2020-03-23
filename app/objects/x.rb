class X
  def self.query(what, a = nil)
    case what
    when "categories"
      [Category.new(name: "hehe")]
    else fail
    end
  end
end