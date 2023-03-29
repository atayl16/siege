# frozen_string_literal: true

class AddFirstXpToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :first_xp, :integer
    add_column :players, :first_lvl, :integer
  end
end
