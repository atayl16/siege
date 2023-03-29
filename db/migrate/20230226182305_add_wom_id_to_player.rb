# frozen_string_literal: true

class AddWomIdToPlayer < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :wom_id, :integer
  end
end
