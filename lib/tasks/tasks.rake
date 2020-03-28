namespace :topics do
  task :import, [:file_path] => :environment do |task, args|
    # category = Category.new
    # category.name = "category"
    # category.save!

    # topic_1 = Topic.build
    # topic_1.add_content("pl", "topic_1")
    # topic_1.save!

    # cate = Categorization.new
    # cate.category = category
    # cate.topic = topic_1
    # cate.save!


    X.transaction do
      category = nil
      File.foreach(args[:file_path]) do |line|
        line.strip!

        next if line.blank?

        if line.include?("category_name:")
          category_name = line.gsub(/\s+/m, " ").strip.split(" ")[1]
          category = X.get("category", { name: category_name })
        else
          fail unless category

          topic = Topic.build
          topic.add_content("pl", line)
          topic.save!

          cat = Categorization.new
          cat.category = category
          cat.topic = topic
          cat.save!
          puts topic.present
        end
      end
    end
  end
end