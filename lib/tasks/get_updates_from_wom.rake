# frozen_string_literal: true

namespace :get_updates_from_wom do
  desc 'Update players inactove status external API'
  task update_players: :environment do
    require 'httparty'
    require 'json'
    require 'erb'
    include ERB::Util

    @players = Player.all
    @players.each do |player|
      name = url_encode(player.name.strip)
      @hash = HTTParty.get(
        "https://api.wiseoldman.net/v2/players/#{name}/gained?period=month",
        headers: { 'Content-Type' => 'application/json' }
      )

      next if @hash['error']

      begin
        player.gained_xp = @hash['data']['skills']['overall']['experience']['gained']
        player.update(gained_xp: player.gained_xp)
        puts "Updated #{player.name}, gained xp: #{player.gained_xp}"
      rescue StandardError => e
        puts "Error updating #{player.name}, #{e}"
      end
    end
  end
end
