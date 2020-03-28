class MainController < ApplicationController
  def home
    @categories = X.query("categories")
    render template: "main"
  end

  def show
    case params["what"]
    when "random_topic_redirect"
      category = X.query("category", { category_id: params["category_id"] })
      topic = X.query("random_topic", { category_id: params["category_id"] })
      return redirect_to X.path_for("show_topic", { topic: topic, category: category })
    when "topic"
      @topic = X.query("topic", { topic_id: params["topic_id"] })
      @category = X.query("category", { category_id: params["category_id"] })
      @categories = X.query("categories")
      render template: "main"
    else fail
    end
  end
end