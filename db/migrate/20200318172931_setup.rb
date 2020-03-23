class Setup < ActiveRecord::Migration[6.0]
  def change
    create_table :topics do |t|
      t.jsonb :content

      t.timestamps null: false
    end

    create_table :categories do |t|
      t.string :name, null: false

      t.timestamps null: false
    end

    create_table :categorisations do |t|
      t.timestamps null: false
    end

    add_reference :categorisations, :topic, foreign_key: { to_table: :topics }, null: false
    add_reference :categorisations, :category, foreign_key: { to_table: :categories }, null: false
  end
end
