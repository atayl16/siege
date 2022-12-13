namespace :update_players do
  desc 'Update players current info from external API'
  task :update_players => :environment do
      require 'httparty'
      @players = Player.all
      @players.each do |player|
        @url = HTTParty.get(
          "https://secure.runescape.com/m=hiscore_oldschool/index_lite.ws?player=#{player.name}",
          :headers =>{'Content-Type' => 'application/json'}
        )
        if @url.split("\n")[0].split(",").map(&:to_i).last == 0 then next end
        player.update( current_xp: @url.split("\n")[0].split(",").map(&:to_i).last )
        player.update( current_lvl: @url.split("\n")[0].split(",").map(&:to_i).second )
        puts "Updated #{player.name}, current xp: #{player.current_xp}, current lvl: #{player.current_lvl}"
      end
  end
end