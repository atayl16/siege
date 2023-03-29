# frozen_string_literal: true

class AddGainedXpToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :gained_xp, :integer
  end
end
