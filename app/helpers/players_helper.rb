# frozen_string_literal: true

module PlayersHelper
  def wom_url(player)
    "https://www.wiseoldman.net/players/#{player.name}"
  end

  def wom_api_url(player)
    "https://api.wiseoldman.net/players/id/#{player.wom_id}"
  end

  def rank(number)
    case number
    when 1
      '🥇 1st'
    when 2
      '🥈 2nd'
    when 3
      '🥉 3rd'
    else
      number.ordinalize
    end
  end
end
