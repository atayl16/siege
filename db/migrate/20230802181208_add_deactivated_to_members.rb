# frozen_string_literal: true

class AddDeactivatedToMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :deactivated, :boolean, default: false
  end
end
