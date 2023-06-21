namespace :get_player_wom_name do
  desc 'Update players WOM ID from external API'
  task :update_players => :environment do
    require 'httparty'
    @players = Player.all
    @players.each do |player|
      @url = HTTParty.get(
        "https://api.wiseoldman.net/v2/players/id/#{player.wom_id}",
        :headers =>{'Content-Type' => 'application/json'}
      )
      if @url["id"] == nil then next end
      
      begin
        player.update( wom_name: @url["displayName"] )
        player.update( name: @url["displayName"]) if player.name != @url["displayName"]
        puts "Updated #{player.name}, wom_id: #{player.wom_name}"
      rescue StandardError => e
        puts "Error updating #{player.name}, #{e}"
      end
    end
  end
end