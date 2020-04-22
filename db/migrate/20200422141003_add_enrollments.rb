class AddEnrollments < ActiveRecord::Migration[6.0]
  def change
    create_table :enrolments do |t|
      t.string :name, null: false
      t.string :contact, null: false
      t.string :status, null: false
      t.string :round, null: false

      t.timestamps null: false
    end
  end
end
