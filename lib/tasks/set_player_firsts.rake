namespace :set_player_firsts do
  desc 'Populate player first entry data for safekeeping'
  task :update_players => :environment do
    @players = Player.all
    @players.each do |player|
      if player.first_xp == nil then player.update( first_xp: player.xp ) end
      if player.first_lvl == nil then player.update( first_lvl: player.lvl ) end
      puts "Updated #{player.name}, first xp: #{player.first_xp}, first lvl: #{player.first_lvl}"
    end
  end
end
