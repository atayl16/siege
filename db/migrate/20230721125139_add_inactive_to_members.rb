class AddInactiveToMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :inactive, :boolean, default: false
  end
end
