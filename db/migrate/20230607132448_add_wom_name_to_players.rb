# frozen_string_literal: true

class AddWomNameToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :wom_name, :string
  end
end
