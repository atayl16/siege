# frozen_string_literal: true

class CreateVars < ActiveRecord::Migration[7.0]
  def change
    create_table :vars do |t|
      t.string :name
      t.text :description
      t.string :value

      t.timestamps
    end
  end
end
