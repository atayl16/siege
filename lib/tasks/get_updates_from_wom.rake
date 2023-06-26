# frozen_string_literal: true

namespace :get_updates_from_wom do
  desc 'Update players inactive status external API'
  task update_players: :environment do
    require 'httparty'
    require 'json'
    require 'erb'
    include ERB::Util

    wom = Rails.application.credentials.dig(:wom, :verificationCode)
    @players = Player.all
    @players.each do |player|
      name = url_encode(player.name.strip)
      @hash = HTTParty.get(
        "https://api.wiseoldman.net/v2/players/#{name}/gained?period=2m",
        headers: { 'Content-Type' => 'application/json' },
        data: { 'verificationCode' => wom }
      )

      next if @hash['error']

      begin
        player.gained_xp = @hash['data']['skills']['overall']['experience']['gained']
        player.update(gained_xp: player.gained_xp)
        puts "Updated #{player.name}, gained xp: #{player.gained_xp}"
      rescue StandardError => e
        puts "Error updating #{player.name}, #{e}"
      end
    end
    end
    
  desc 'Update events from external API'
  task update_events: :environment do
    wom = Rails.application.credentials.dig(:wom, :verificationCode)
    @events_url = HTTParty.get(
      "https://api.wiseoldman.net/v2/groups/2928/competitions?limit=1",
      headers: { 'Content-Type' => 'application/json' },
      data: { 'verificationCode' => wom }
    )
    @data = JSON.parse(@events_url.body)
    @data.each do |event|
      if Event.exists?(wom_id: event['id'].to_s)
        @event = Event.find_by(wom_id: event['id'])
        @event.update(name: event['title'])
        @event.update(starts: event['startsAt'])
        @event.update(ends: event['endsAt'])
        @event.update(metric: event['metric'])
        puts "Updated event #{event['title']}"
        if @event.ends < Time.now and @event.winner.nil?
          winners_url = HTTParty.get(
            "https://api.wiseoldman.net/v2/competitions/#{event['id']}/top-history",
            headers: { 'Content-Type' => 'application/json' }
          )
          @winner_data = JSON.parse(winners_url.body)
          @event.update(winner: @winner_data[0]['player']['displayName'])
          puts "Updated winner for event #{event['title']} to #{@winner_data[0]['player']['displayName']}"
        end
      else
        @event = Event.new
        @event.wom_id = event['id']
        @event.name = event['metric']
        @event.starts = event['startsAt']
        @event.ends = event['endsAt']
        @event.metric = event['metric']
        if @event.ends < Time.now and @event.winner.nil?
          winners_url = HTTParty.get(
            "https://api.wiseoldman.net/v2/competitions/#{event['id']}/top-history",
            headers: { 'Content-Type' => 'application/json' }
          )
          @winner_data = JSON.parse(winners_url.body)
          @event.update(winner: @winner_data[0]['player']['displayName'])
          puts "Updated winner for event #{event['title']} to #{@winner_data[0]['player']['displayName']}"
        end
        
        @event.save
        puts "Created event #{event['id']}"
      end
    end
    


  end
end

# Sample Output:
# [
#   {
#     "player": {
#       "id": 127754,
#       "username": "matiieu",
#       "displayName": "Matiieu",
#       "type": "ironman",
#       "build": "main",
#       "country": null,
#       "status": "active",
#       "exp": 131693581,
#       "ehp": 636.3791899999997,
#       "ehb": 147.17091,
#       "ttm": 1128.26096,
#       "tt200m": 21816.43212,
#       "registeredAt": "2021-01-04T03:32:34.771Z",
#       "updatedAt": "2022-10-31T07:02:47.126Z",
#       "lastChangedAt": "2021-09-06T05:04:08.102Z",
#       "lastImportedAt": null
#     },
#     "history": [
#       {
#         "value": 810,
#         "date": "2021-01-31T23:51:59.079Z"
#       },
#       {
#         "value": 797,
#         "date": "2021-01-31T23:45:18.450Z"
#       },
#       {
#         "value": 525,
#         "date": "2021-01-25T14:36:57.616Z"
#       },
#       {
#         "value": 485,
#         "date": "2021-01-25T05:10:16.939Z"
#       }
#     ]
#   }