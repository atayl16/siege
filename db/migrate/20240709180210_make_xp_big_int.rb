class MakeXpBigInt < ActiveRecord::Migration[7.0]
  def change
    change_column :players, :xp, :bigint
    change_column :players, :current_xp, :bigint
    change_column :players, :first_xp, :bigint
    change_column :players, :gained_xp, :bigint
  end
end
