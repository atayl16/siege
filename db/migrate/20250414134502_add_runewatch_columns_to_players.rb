class AddRunewatchColumnsToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :runewatch_reported, :boolean, default: false
    add_column :players, :runewatch_whitelisted, :boolean, default: false
    add_column :players, :runewatch_whitelist_reason, :text
    add_column :players, :runewatch_whitelisted_at, :datetime
  end
end
