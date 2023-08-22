# frozen_string_literal: true

class AddDeactivatedStatsToMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :deactivated_xp, :integer
    add_column :players, :deactivated_lvl, :integer
    add_column :players, :deactivated_date, :datetime
    add_column :players, :reactivated_xp, :integer
    add_column :players, :reactivated_lvl, :integer
    add_column :players, :reactivated_date, :datetime
  end
end
