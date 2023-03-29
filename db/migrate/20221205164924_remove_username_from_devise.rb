# frozen_string_literal: true

class RemoveUsernameFromDevise < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :username, :string
  end
end
