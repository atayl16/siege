namespace :hourly_tasks do
  desc "Run all update tasks consecutively"
  task run_all_updates: :environment do
	Rake::Task['update_players:update_players'].invoke
	Rake::Task['wom:update_all'].invoke
	Rake::Task['get_updates_from_wom:update_players'].invoke
	Rake::Task['get_player_wom_name:update_players'].invoke
	Rake::Task['get_updates_from_wom:update_player_womrole'].invoke
  end
end
