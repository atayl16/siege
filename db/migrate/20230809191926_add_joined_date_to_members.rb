# frozen_string_literal: true

class AddJoinedDateToMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :joined_date, :datetime
  end
end
