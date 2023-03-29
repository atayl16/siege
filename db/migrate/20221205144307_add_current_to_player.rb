# frozen_string_literal: true

class AddCurrentToPlayer < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :current_lvl, :integer
    add_column :players, :current_xp, :integer
  end
end
