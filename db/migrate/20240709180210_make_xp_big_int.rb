class MakeXpBigInt < ActiveRecord::Migration[7.0]
  class ChangeIntegerLimitInYourTable < ActiveRecord::Migration[6.0]
    def up
      change_column :players, :xp, :bigint
      change_column :players, :current_xp, :bigint
      change_column :players, :first_xp, :bigint
      change_column :players, :gained_xp, :bigint
    end
  
    def down
      change_column :players, :xp, :integer
      change_column :players, :current_xp, :integer
      change_column :players, :first_xp, :integer
      change_column :players, :gained_xp, :integer
    end
  end
end
