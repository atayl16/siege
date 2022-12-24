class AddOldNamesToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :old_names, :string
  end
end
