class AddWinnerToEvents < ActiveRecord::Migration[7.0]
  def change
  add_column :events, :winner, :string
  end
end
