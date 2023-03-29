# frozen_string_literal: true

class AddDefaultCurrentToPlayer < ActiveRecord::Migration[7.0]
  def change
    change_column :players, :current_lvl, :integer, default: 0
    change_column :players, :current_xp, :integer, default: 0
  end
end
