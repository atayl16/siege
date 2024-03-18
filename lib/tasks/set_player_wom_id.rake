# frozen_string_literal: true

namespace :set_player_wom_id do
  desc 'Update players WOM ID from external API'
  task set_player_wom_id: :environment do
    wom = Rails.application.credentials.dig(:wom, :verificationCode)
    require 'httparty'
    @players = Player.all
    @players.each do |player|
      begin
        response = HTTParty.get(
          "https://api.wiseoldman.net/v2/players/#{player.name.gsub(' ', '%20')}",
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

        player.update(wom_id: @url['id'])
        puts "Updated #{player.name}, wom_id: #{player.wom_id}"
      rescue StandardError => e
        puts "Error updating #{player.name}, #{e}"
      end
    end
  end
end
