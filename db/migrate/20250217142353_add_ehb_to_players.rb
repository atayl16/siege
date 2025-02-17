class AddEhbToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :ehb, :integer, default: 0
  end
end
