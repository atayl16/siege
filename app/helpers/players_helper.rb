# frozen_string_literal: true

module PlayersHelper
  def wom_url(player)
    "https://www.wiseoldman.net/players/#{player.name}"
  end

  def wom_api_url(player)
    "https://api.wiseoldman.net/players/id/#{player.wom_id}"
  end
end
