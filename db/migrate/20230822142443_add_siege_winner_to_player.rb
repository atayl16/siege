# frozen_string_literal: true

class AddSiegeWinnerToPlayer < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :siege_winner_place, :integer, default: 0
  end
end
