class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.integer :wom_id
      t.string :name
      t.datetime :starts
      t.datetime :ends
      t.string :metric

      t.timestamps
    end
  end
end
