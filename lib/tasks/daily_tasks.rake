namespace :daily_tasks do
  desc "Run all update tasks consecutively"
  task run_all_updates: :environment do
	Rake::Task['get_updates_from_wom:update_events'].invoke
	Rake::Task['get_updates_from_wom:update_player_achievements'].invoke
	Rake::Task['get_updates_from_wom:update_player_attributes'].invoke
	Rake::Task['get_updates_from_wom:update_player_womrole'].invoke
	Rake::Task['get_updates_from_wom:update_player_name_history'].invoke
	Rake::Task['get_updates_from_wom:update_group_achievements'].invoke
	Rake::Task['get_updates_from_wom:update_player_competition_score'].invoke
  end
end
