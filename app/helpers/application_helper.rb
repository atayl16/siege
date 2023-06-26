# frozen_string_literal: true

module ApplicationHelper
  #player_count = Player.all.count + 2
  def player_count
   Player.all.count + 2
  end
end
