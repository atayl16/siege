# frozen_string_literal: true

class AddTitleToPlayer < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :title, :string
  end
end
