namespace :topics do
  task :import, [:file_path] => :environment do |task, args|
    file_path = args[:file_path] || Rails.root.join("tematy.txt")

    X.transaction do
      category = nil
      File.foreach(file_path) do |line|
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

  task :create_user_topics_category => :environment do |task, args|
    category = Category.new(name: "Dodane-przez-uzytkownikow")
    category.save!
  end
end