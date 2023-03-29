# frozen_string_literal: true

namespace :set_player_firsts do
  desc 'Populate player first entry data for safekeeping'
  task update_players: :environment do
    @players = Player.all
    @players.each do |player|
      player.update(first_xp: player.xp) if player.first_xp.nil?
      player.update(first_lvl: player.lvl) if player.first_lvl.nil?
      puts "Updated #{player.name}, first xp: #{player.first_xp}, first lvl: #{player.first_lvl}"
    rescue StandardError => e
      puts "Error updating #{player.name}, #{e}"
    end
  end
end
