class X
  def self.transaction(&block)
    ActiveRecord::Base.transaction(&block)
  end

  def self.query(what, a = nil)
    case what
    when "category"
      if a.key?(:name)
        Category.find_by(name: a[:name])
      elsif a.key?(:category_id)
        Category.find_by(id: a[:category_id])
      else fail
      end
    when "categories"
      Category.all.to_a
    when "random_topic"
      if a[:category_id]
        Topic.joins(:categorizations).where(categorizations: { category_id: a[:category_id] }).order("RANDOM()").limit(1).first
      else
        Topic.order("RANDOM()").limit(1).first
      end
    when "topic"
      if a.key?(:topic_id)
        Topic.find_by(id: a[:topic_id])
      else fail
      end
    else fail
    end
  end

  def self.path_for(what, a = nil)
    options = { only_path: true }

    case what
    when "show_random_topic_redirect"
      custom_options = { controller: "main", action: "show", what: "random_topic_redirect", category_id: a[:category]&.id }.compact
      custom_options.merge!(options)
      Rails.application.routes.url_helpers.url_for(custom_options)
    when "show_topic"
      if a[:category]
        category_options = { category_id: a[:category].id }
      else
        category_options = {}
      end
      custom_options = { controller: "main", action: "show", what: "topic", topic_id: a[:topic].id }
      custom_options.merge!(category_options)
      custom_options.merge!(options)
      Rails.application.routes.url_helpers.url_for(custom_options)
    else fail
    end
  end

  def self.get(what, a)
    case what
    when "category"
      if a.key?(:name)
        category = X.query("category", a)
        if category.nil?
          category = Category.new(name: a[:name])
          category.save!
        end
        category
      else fail
      end
    else fail
    end
  end
end