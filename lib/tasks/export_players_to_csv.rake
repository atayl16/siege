# frozen_string_literal: true

namespace :export_players_to_csv do
  desc 'Export players to csv'
  task export_players: :environment do
    require 'csv'
    require 'aws-sdk-s3'
    file = File.open('players.csv', 'w')

    @players = Player.all
    CSV.open('players.csv', 'wb') do |csv|
      csv << %w[name lvl xp title rank current_lvl current_xp first_xp first_lvl gained_xp old_names wom_id wom_name score inactive deactivated deactivated_xp deactivated_lvl deactivated_date reactivated_xp reactivated_lvl reactivated_date]
      @players.each do |player|
        csv << [player.name, player.lvl, player.xp, player.title, player.rank, player.current_lvl, player.current_xp,
                player.first_xp, player.first_lvl, player.gained_xp, player.old_names, player.wom_id, player.wom_name,
                player.score, player.inactive, player.deactivated, player.deactivated_xp, player.deactivated_lvl,
                player.deactivated_date, player.reactivated_xp, player.reactivated_lvl, player.reactivated_date]        
      end
    end

    file.close
    # export to s3 bucket arn:aws:s3:::siege-clan
    s3 = Aws::S3::Resource.new(region: 'us-east-1')
    obj = s3.bucket('siege-clan').object('players-#{Date.today}.csv')
    obj.upload_file('players.csv')
    
  end
end
