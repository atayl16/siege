# frozen_string_literal: true

namespace :get_updates_from_wom do
  desc 'Update players kickable status external API'
  task update_players: :environment do
    require 'httparty'
    require 'json'
    require 'erb'
    include ERB::Util

    wom = Rails.application.credentials.dig(:wom, :verificationCode)
    @players = Player.where(deactivated: false)
    @players.each do |player|
      name = url_encode(player.name.strip)
      @hash = HTTParty.get(
        "https://api.wiseoldman.net/v2/players/#{name}/gained?period=2m",
        headers: { 'Content-Type' => 'application/json' },
        data: { 'verificationCode' => wom }
      )

      if @hash.code == 429
        puts "Rate limit exceeded, sleeping for 60 seconds"
        sleep(60)
        redo
      end

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
      'https://api.wiseoldman.net/v2/groups/2928/competitions?limit=1',
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
        if (@event.ends < Time.now) && @event.winner.nil?
          winners_url = HTTParty.get(
            "https://api.wiseoldman.net/v2/competitions/#{event['id']}/top-history",
            headers: { 'Content-Type' => 'application/json' }
          )

          if winners_url.code == 429
            puts "Rate limit exceeded, sleeping for 60 seconds"
            sleep(60)
            redo
          end

          @winner_data = JSON.parse(winners_url.body)
          @event.update(winner: @winner_data[0]['player']['displayName'])
          puts "Updated winner for event #{event['title']} to #{@winner_data[0]['player']['displayName']}"
        end
      else
        @event = Event.new
        @event.wom_id = event['id']
        @event.name = event['title']
        @event.starts = event['startsAt']
        @event.ends = event['endsAt']
        @event.metric = event['metric']
        if (@event.ends < Time.now) && @event.winner.nil?
          winners_url = HTTParty.get(
            "https://api.wiseoldman.net/v2/competitions/#{event['id']}/top-history",
            headers: { 'Content-Type' => 'application/json' }
          )

          if winners_url.code == 429
            puts "Rate limit exceeded, sleeping for 60 seconds"
            sleep(60)
            redo
          end

          @winner_data = JSON.parse(winners_url.body)
          @event.update(winner: @winner_data[0]['player']['displayName'])
          puts "Updated winner for event #{event['title']} to #{@winner_data[0]['player']['displayName']}"
        end

        @event.save
        puts "Created event #{event['id']}"
      end
    end
  end

  desc 'Update player attributes from external API'
  task update_player_attributes: :environment do
    require 'httparty'
    require 'json'
    require 'erb'
    include ERB::Util

    wom = Rails.application.credentials.dig(:wom, :verificationCode)
    api_key = Rails.application.credentials.dig(:wom, :apiKey)
    @players = Player.where(deactivated: false)
    @players.each do |player|
      name = url_encode(player.name.strip)
      begin
        response = HTTParty.get(
          "https://api.wiseoldman.net/v2/players/#{name}",
          headers: { 'Content-Type' => 'application/json', "x-api-key": api_key },
          data: { 'verificationCode' => wom }
        )

        if response.code == 429
          puts "Rate limit exceeded, sleeping for 60 seconds"
          sleep(60)
          redo
        end

        @hash = response.parsed_response
        next if @hash['error']

        player.combat = @hash['combatLevel']
        player.build = @hash['type']

        if player.update(combat: player.combat, build: player.build)
          puts "Updated #{player.name}, combat: #{player.combat}, build: #{player.build}"
        end
      rescue StandardError => e
        puts "Error updating #{player.name}, #{e}"
      end
    end
  end

  desc 'Update player achievements from external API'
  task update_player_achievements: :environment do
    require 'httparty'
    require 'json'
    require 'erb'
    include ERB::Util

    wom = Rails.application.credentials.dig(:wom, :verificationCode)
    api_key = Rails.application.credentials.dig(:wom, :apiKey)
    @players = Player.where(deactivated: false)
    @players.each do |player|
      name = url_encode(player.name.strip)
      begin
        response = HTTParty.get(
          "https://api.wiseoldman.net/v2/players/#{name}/achievements",
          headers: { 'Content-Type' => 'application/json', "x-api-key": api_key },
          data: { 'verificationCode' => wom }
        )

        if response.code == 429
          puts "Rate limit exceeded, sleeping for 60 seconds"
          sleep(60)
          redo
        end

        @hash = JSON.parse(response.body)
        player.update(achievements: @hash)
        puts "Updated #{player.name}, achievements: #{player.achievements}"
      rescue StandardError => e
        puts "Error updating #{player.name}, #{e}"
      end
    end
  end

  desc 'Get old player names from external API'
  task update_player_name_history: :environment do
    require 'httparty'
    require 'json'
    require 'erb'
    include ERB::Util

    wom = Rails.application.credentials.dig(:wom, :verificationCode)
    api_key = Rails.application.credentials.dig(:wom, :apiKey)
    @players = Player.where(deactivated: false)
    @players.each do |player|
      name = url_encode(player.name.strip)
      begin
        response = HTTParty.get(
          "https://api.wiseoldman.net/v2/players/#{name}/names",
          headers: { 'Content-Type' => 'application/json', "x-api-key": api_key },
          data: { 'verificationCode' => wom }
        )

        if response.code == 429
          puts "Rate limit exceeded, sleeping for 60 seconds"
          sleep(60)
          redo
        end

        @hash = JSON.parse(response.body)
        player.update(old_names: @hash)
        puts "Updated #{player.name}, names: #{player.old_names}"
      rescue StandardError => e
        puts "Error updating #{player.name}, #{e}"
      end
    end
  end

  desc 'Update group achievements from external API'
  task update_group_achievements: :environment do
    require 'httparty'
    require 'json'
    require 'erb'
    include ERB::Util

    wom = Rails.application.credentials.dig(:wom, :verificationCode)
    api_key = Rails.application.credentials.dig(:wom, :apiKey)
    url = 'https://api.wiseoldman.net/v2/groups/2928/achievements?limit=15'
    @hash = HTTParty.get(
      url,
      headers: { 'Content-Type' => 'application/json', "x-api-key": api_key },
      data: { 'verificationCode' => wom }
    )
    begin
      response = HTTParty.get(
        url,
        headers: { 'Content-Type' => 'application/json', "x-api-key": api_key },
        data: { 'verificationCode' => wom }
      )

      if response.code == 429
        puts "Rate limit exceeded, sleeping for 60 seconds"
        sleep(60)
        redo
      end

      Achievement.delete_all
      @hash = JSON.parse(response.body)
      @hash.each do |achievement|
        @achievement = Achievement.new
        @achievement.wom_id = achievement['playerId']
        @achievement.name = achievement['name']
        @achievement.date = achievement['createdAt']
        @achievement.player_name = achievement['player']['displayName']
        @achievement.save
        puts "Created group achievement #{achievement['name']}"
      end
    rescue StandardError => e
      puts "Error updating group achievements, #{e}"
    end
  end

  desc 'Update player competition score from external API'
  task update_player_competition_score: :environment do
    require 'httparty'
    require 'json'
    require 'erb'
    include ERB::Util

    wom = Rails.application.credentials.dig(:wom, :verificationCode)
    api_key = Rails.application.credentials.dig(:wom, :apiKey)
    @players = Player.where(deactivated: false, build: 'ironman')
    @players.each do |player|
      name = url_encode(player.name.strip)
      begin
        response = HTTParty.get(
          "https://api.wiseoldman.net/v2/players/#{name}/competitions/standings?status=ongoing",
          headers: { 'Content-Type' => 'application/json', "x-api-key": api_key },
          data: { 'verificationCode' => wom }
        )

        if response.code == 429
          puts "Rate limit exceeded, sleeping for 60 seconds"
          sleep(60)
          redo
        end

        @hash = JSON.parse(response.body)
        (0..5).each do |i|
          if @hash[i]
            competition = {
              @hash[i]['competition']['metric'] => @hash[i]['progress']['gained']
            }
            player.update("competition_#{i+1}".to_sym => competition)
          else
            player.update("competition_#{i+1}".to_sym => nil)
          end
        end

        puts "Updated #{player.name}"
      rescue StandardError => e
        puts "Error updating #{player.name}, #{e}"
      end
    end

  end
    
end

# curl -X GET https://api.wiseoldman.net/v2/players/zezima/competitions/standings?status=ongoing \
  #-H "Content-Type: application/json"
# [
#   {
#     "playerId": 36994,
#     "competitionId": 16583,
#     "teamName": null,
#     "createdAt": "2022-10-24T14:16:37.339Z",
#     "updatedAt": "2022-10-28T09:53:31.638Z",
#     "progress": {
#       "gained": 4332129,
#       "start": 2097664,
#       "end": 6429793
#     },
#     "levels": {
#       "gained": 11,
#       "start": 80,
#       "end": 91
#     },
#     "rank": 1,
#     "competition": {
#       "id": 16583,
#       "title": "Skill of the Week #60: Thieving",
#       "metric": "thieving",
#       "type": "classic",
#       "startsAt": "2022-10-24T22:00:00.000Z",
#       "endsAt": "2022-10-30T22:00:00.000Z",
#       "groupId": 1088,
#       "score": 626,
#       "createdAt": "2022-10-24T14:16:37.339Z",
#       "updatedAt": "2022-10-26T20:20:05.150Z",
#       "group": {
#         "id": 1088,
#         "name": "Wild",
#         "clanChat": "Wild",
#         "description": "Clan Wild, Created from the community of The Wilderness Podcast",
#         "homeworld": 386,
#         "verified": true,
#         "patron": false,
#         "profileImage": null,
#         "bannerImage": null,
#         "score": 440,
#         "createdAt": "2021-05-04T13:03:02.851Z",
#         "updatedAt": "2022-10-25T15:46:55.761Z",
#         "memberCount": 729
#       },
#       "participantCount": 729
#     }
#   }
# ]