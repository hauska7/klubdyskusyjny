require "json"

class X
  def self.parse_json(json)
    JSON.parse(json)
  end

  def self.to_json(topic)
    if topic.is_a?(Topic)
      topic.content.to_json
    else fail
    end
  end

  def self.transaction(&block)
    ActiveRecord::Base.transaction(&block)
  end

  def self.query(what, a = nil)
    a = a.permit!.to_h.symbolize_keys if a.is_a?(ActionController::Parameters)

    case what
    when "category"
      if a.is_a?(Hash)
        if a.key?(:name)
          Category.find_by(name: a[:name])
        elsif a.key?(:category_id)
          Category.find_by(id: a[:category_id])
        else fail
        end
      elsif a.is_a?(String)
        if a == "user_topics"
          Category.find_by(name: "Dodane-przez-uzytkownikow")
        else fail
        end
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
    when "enrolments"
      if a[:round] == "1"
        Enrolment.where(round: "1").to_a
      elsif a.blank?
        Enrolment.all.to_a
      else fail
      end
    else fail
    end
  end

  def self.path_for(what, a = {})
    options = { only_path: true }

    case what
    when "root"
      custom_options = { controller: "main", action: "home" }
      custom_options.merge!(options)
      Rails.application.routes.url_helpers.url_for(custom_options)
    when "login"
      custom_options = { controller: "main", action: "login", user: "admin" }
      custom_options.merge!(options)
      Rails.application.routes.url_helpers.url_for(custom_options)
    when "logout"
      custom_options = { controller: "main", action: "logout" }
      custom_options.merge!(options)
      Rails.application.routes.url_helpers.url_for(custom_options)
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
    when "show_enrolments"
      custom_options = { controller: "main", action: "show", what: "enrolments", round: a[:round] }
      custom_options.merge!(options)
      Rails.application.routes.url_helpers.url_for(custom_options)
    when "edit_topic"
      custom_options = { controller: "main", action: "show", what: "topic", topic_id: a[:topic].id, edit: "true" }
      custom_options.merge!(options)
      Rails.application.routes.url_helpers.url_for(custom_options)
    when "new_topic"
      custom_options = { controller: "main", action: "show", what: "new" }
      custom_options.merge!(options)
      Rails.application.routes.url_helpers.url_for(custom_options)
    when "new_enrolment"
      custom_options = { controller: "main", action: "show", what: "new_enrolment" }
      custom_options.merge!(options)
      Rails.application.routes.url_helpers.url_for(custom_options)
    when "delete_topic"
      custom_options = { controller: "main", action: "delete", what: "topic", topic_id: a[:topic].id }
      custom_options.merge!(options)
      Rails.application.routes.url_helpers.url_for(custom_options)
    when "update_topic"
      custom_options = { controller: "main", action: "update", what: "topic", topic_id: a[:topic].id }
      custom_options.merge!(options)
      Rails.application.routes.url_helpers.url_for(custom_options)
    when "create_topic"
      custom_options = { controller: "main", action: "create", what: "topic" }
      custom_options.merge!(options)
      Rails.application.routes.url_helpers.url_for(custom_options)
    when "create_enrolment"
      custom_options = { controller: "main", action: "create", what: "enrolment" }
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