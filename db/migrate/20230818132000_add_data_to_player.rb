# frozen_string_literal: true

class AddDataToPlayer < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :combat, :integer, default: 0
    add_column :players, :build, :string
    add_column :players, :achievement_name, :string
    add_column :players, :achievement_date, :datetime
    add_column :players, :achievements, :json
  end
end
