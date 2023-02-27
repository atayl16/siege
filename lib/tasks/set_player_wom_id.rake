namespace :set_player_wom_id do
  desc 'Update players WOM ID from external API'
  task :set_player_wom_id => :environment do
      require 'httparty'
      @players = Player.all
      @players.each do |player|
        @url = HTTParty.get(
          "https://api.wiseoldman.net/v2/players/#{player.name.gsub(" ","%20")}",
          :headers =>{'Content-Type' => 'application/json'}
        )
        if @url["id"] == nil then next end
        player.update( wom_id: @url["id"] )
        puts "Updated #{player.name}, wom_id: #{player.wom_id}"
      end
  end
end