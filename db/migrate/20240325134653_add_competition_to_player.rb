class AddCompetitionToPlayer < ActiveRecord::Migration[7.0]
  def change
  # add JSON column to store competition data
    add_column :players, :competition_1, :jsonb, default: {}
    add_column :players, :competition_2, :jsonb, default: {}
    add_column :players, :competition_3, :jsonb, default: {} 
    add_column :players, :competition_4, :jsonb, default: {} 
    add_column :players, :competition_5, :jsonb, default: {} 
    add_column :players, :competition_6, :jsonb, default: {} 
  end
end
