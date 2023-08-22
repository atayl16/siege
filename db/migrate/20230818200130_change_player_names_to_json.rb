# frozen_string_literal: true

class ChangePlayerNamesToJson < ActiveRecord::Migration[7.0]
  def change
    change_column :players, :old_names, :json, using: 'old_names::json'
  end
end
