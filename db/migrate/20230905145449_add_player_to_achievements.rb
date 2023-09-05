class AddPlayerToAchievements < ActiveRecord::Migration[7.0]
  def change
    add_column :achievements, :player_name, :string
  end
end
