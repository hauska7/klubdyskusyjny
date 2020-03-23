class MainController < ApplicationController
  def home
    @categories = X.query("categories")
    render template: "main"
  end

  def get
    case params["what"]
    when "random_topic"
      params["category_id"]
      @topic = X.query("random_topic", { category_id: params["category_id"] })
      render json: {}
    else fail
    end
  end
end