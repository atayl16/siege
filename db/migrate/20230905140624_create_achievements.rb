class CreateAchievements < ActiveRecord::Migration[7.0]
  def change
    create_table :achievements do |t|
      t.integer :wom_id
      t.string :name
      t.datetime :date

      t.timestamps
    end
  end
end
