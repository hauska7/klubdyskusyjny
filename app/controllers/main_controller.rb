class MainController < ApplicationController
  def home
    redirect_to X.path_for("show_random_topic_redirect")
  end

  def login
    session[:user] = params["user"]

    redirect_to X.path_for("show_random_topic_redirect")
  end

  def logout
    session[:user] = nil

    redirect_to X.path_for("show_random_topic_redirect")
  end

  def show
    case params["what"]
    when "random_topic_redirect"
      category = X.query("category", { category_id: params["category_id"] })
      topic = X.query("random_topic", { category_id: params["category_id"].presence }.compact )
      return redirect_to X.path_for("show_topic", { topic: topic, category: category })
    when "topic"
      @topic = X.query("topic", { topic_id: params["topic_id"] })
      @category = @topic.categories.first
      @categories = X.query("categories")

      if params["edit"] == "true"
        @edit = true
      else
        @show = true
      end

      render template: "main"
    when "new"
      @categories = X.query("categories")

      @new = true

      render template: "main"
    else fail
    end
  end

  def create
    category = X.query("category", params)

    X.transaction do
      unless category
        category = Category.new(name: params["category_name"])
        category.save!
      end

      topic = Topic.build
      topic.add_content("pl", params["topic_content"])
      topic.save!

      cat = Categorization.new
      cat.category = category
      cat.topic = topic
      cat.save!

      return redirect_to X.path_for("show_topic", { topic: topic })
    end
  end

  def update
    case params["what"]
    when "topic"
      topic = X.query("topic", params)
      category = X.query("category", params)

      X.transaction do
        if category.nil?
          topic.categorizations.destroy_all
        else
          unless topic.categories.include?(category)
            topic.categorizations.destroy_all
            cat = Categorization.new
            cat.category = category
            cat.topic = topic
            cat.save!
          end
        end

        topic.content = X.parse_json(params["content"])
        topic.save!
      end
    else fail
    end

    redirect_to X.path_for("show_topic", { topic: topic })
  end

  def delete
    case params["what"]
    when "topic"
      topic = X.query("topic", { topic_id: params["topic_id"] })

      X.transaction do
        topic.categorizations.destroy_all
        topic.destroy!
      end

      redirect_to X.path_for("show_random_topic_redirect")
    else fail
    end
  end
end