class AddWomroleToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :womrole, :string
  end
end
