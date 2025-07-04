# frozen_string_literal: true

class CreatePlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :players do |t|
      t.string :name
      t.integer :xp
      t.integer :lvl

      t.timestamps
    end
  end
end
