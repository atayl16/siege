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
      @hash = HTTParty.get(
        "https://api.wiseoldman.net/v2/players/#{name}",
        headers: { 'Content-Type' => 'application/json', "x-api-key": api_key },
        data: { 'verificationCode' => wom }
      )

      next if @hash['error']

      begin
        player.combat = @hash['combatLevel']
        player.build = @hash['type']
        player.update(combat: player.combat, build: player.build)
        puts "Updated #{player.name}, combat: #{player.combat}, build: #{player.build}"
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
      @hash = HTTParty.get(
        "https://api.wiseoldman.net/v2/players/#{name}/achievements",
        headers: { 'Content-Type' => 'application/json', "x-api-key": api_key },
        data: { 'verificationCode' => wom }
      )

      begin
        @hash = JSON.parse(@hash.body)
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
      @hash = HTTParty.get(
        "https://api.wiseoldman.net/v2/players/#{name}/names",
        headers: { 'Content-Type' => 'application/json', "x-api-key": api_key },
        data: { 'verificationCode' => wom }
      )

      begin
        @hash = JSON.parse(@hash.body)
        player.update(old_names: @hash)
        puts "Updated #{player.name}, names: #{player.old_names}"
      rescue StandardError => e
        puts "Error updating #{player.name}, #{e}"
      end
    end
  end
end
