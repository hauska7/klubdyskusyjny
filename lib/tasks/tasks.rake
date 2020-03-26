namespace :topics do
  task :import => :environment do
    category = Category.new
    category.name = "category"
    category.save!

    topic_1 = Topic.build
    topic_1.add_content("pl", "topic_1")
    topic_1.save!

    cate = Categorization.new
    cate.category = category
    cate.topic = topic_1
    cate.save!
  end
end