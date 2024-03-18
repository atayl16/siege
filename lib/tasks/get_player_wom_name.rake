# frozen_string_literal: true

namespace :get_player_wom_name do
  desc 'Update players WOM ID from external API'
  task update_players: :environment do
    require 'httparty'

    wom = Rails.application.credentials.dig(:wom, :verificationCode)
    @players = Player.all
    @players.each do |player|
      response = HTTParty.get(
        "https://api.wiseoldman.net/v2/players/id/#{player.wom_id}",
        headers: { 'Content-Type' => 'application/json' },
        data: { 'verificationCode' => wom }
      )

      if response.code == 429
        puts "Rate limit exceeded, sleeping for 60 seconds"
        sleep(60)
        redo
      end

      @url = response.parsed_response
      next if @url['id'].nil?

      begin
        player.update(wom_name: @url['displayName'])
        player.update(name: @url['displayName']) if player.name != @url['displayName']
        puts "Updated #{player.name}, wom_name: #{player.wom_name}"
      rescue StandardError => e
        puts "Error updating #{player.name}, #{e}"
      end
    end
  end
end
