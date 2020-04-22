class MainController < ApplicationController
  def home
    @show_home = true
    render template: "main"
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
      if topic
        return redirect_to X.path_for("show_topic", { topic: topic, category: category })
      else
        topic = X.query("random_topic", { category_id: nil }.compact )
        return redirect_to X.path_for("show_topic", { topic: topic })
      end
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
      if admin?
        @categories = X.query("categories")
        @new = true
      elsif !admin?
        @new_user_topic = true
      else fail
      end

      render template: "main"
    when "new_enrolment"
      @new_enrolment = true

      render template: "main"
    when "enrolments"
      @enrolments = X.query("enrolments", params)
      @show_enrolments = "enrolments"

      render template: "main"
    else fail
    end
  end

  def admin?
    session[:user].present?
  end

  def create
    case params["what"]
    when "topic"
      X.transaction do
        if admin?
          category = X.query("category", params)

          unless category
            category = Category.new(name: params["category_name"])
            category.save!
          end
        elsif !admin?
          category = X.query("category", "user_topics")
        else fail
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
    when "enrolment"
      return redirect_to X.path_for("root") unless params["name"].present? && params["contact"].present?

      enrolment = Enrolment.new
      enrolment.name = params["name"]
      enrolment.contact = params["contact"]
      enrolment.round = "1"
      enrolment.status = "created"
      enrolment.save!

      return redirect_to X.path_for("show_enrolments", { round: "1" })
    else fail
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