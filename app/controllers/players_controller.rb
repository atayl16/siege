# frozen_string_literal: true

class PlayersController < ApplicationController
  include ERB::Util
  before_action :set_player,
                only: %i[show edit update destroy delete call_osrs_api update_rank add_siege_score update_member_on_wom add_member_to_wom
                         remove_member_from_wom switch_role]
  before_action :authenticate_user!, except: %i[show index leaderboard competition]
  before_action :store_location

  # GET /players or /players.json
  def index
    @players = Player.where(deactivated: false)
    # Sorty by siege winner place asc, then by clan_xp desc
    @clan = @players.where(title: nil).sort_by { |player| [player.place.to_i, player.clan_xp.to_i] }.reverse
    @officers = @players.where.not(title: nil).in_order_of(:title,
                                                           ['Owner', 'Deputy Owner', 'General', 'Captain', 'PvM Organizer'])
    @competitors = Player.where(score: 1.., deactivated: false).sort_by(&:score).reverse.first(3)
    @events = Event.where('ends >= ?', Time.now).order('ends ASC').all
  end

  def leaderboard
    @players = Player.where(deactivated: false)
    @competitors = @players.where(score: 1..).sort_by(&:score).reverse
    @winners = @players.where(siege_winner_place: 1..3).sort_by(&:siege_winner_place)
  end

  def deleted
    @deleted_players = Player.where(deactivated: true).order('deactivated_date DESC')
    @reactivated_players = Player.where(reactivated_date: ..Time.now.end_of_month)
  end

  def table
    @clan = Player.where(deactivated: false)
    @players = case params[:sort]
               when 'clan_xp'
                 @clan.sort_by(&:clan_xp).reverse
               when 'needs_update'
                 @clan.sort_by { |player| player.needs_update.to_s }.reverse
               when 'last_update'
                 @clan.sort_by(&:updated_at).reverse
               else 'name'
                 @clan.order('LOWER(name)')
               end
    @competitors = @clan.where(score: 1..).sort_by(&:score).reverse
    @reported_clan_members = fetch_reported_clan_members
  end

  def competition
    @clan = Player.where(deactivated: false, build: ['ironman', 'ultimate'])
    @titles = (1..6).map do |i|
      competition = @clan.first.send("competition_#{i}")
      if competition
        competition.keys.find { |key| competition[key] }
      end
    end.compact
    @players = case params[:sort]
               when 'competition_1'
                  @clan.sort_by { |player| player.competition_1.present? ? player.competition_1.first[1].to_i : 0 }.reverse
                when 'competition_2'
                  @clan.sort_by { |player| player.competition_2.present? ? player.competition_2.first[1].to_i : 0 }.reverse
                when 'competition_3'
                  @clan.sort_by { |player| player.competition_3.present? ? player.competition_3.first[1].to_i : 0 }.reverse
                when 'competition_4'
                  @clan.sort_by { |player| player.competition_4.present? ? player.competition_4.first[1].to_i : 0 }.reverse
                when 'competition_5'
                  @clan.sort_by { |player| player.competition_5.present? ? player.competition_5.first[1].to_i : 0 }.reverse
                when 'competition_6'
                  @clan.sort_by { |player| player.competition_6.present? ? player.competition_6.first[1].to_i : 0 }.reverse
                when 'name'
                  @clan.order('LOWER(name)')
               else
                 @clan.sort_by { |player| player.competition_1.present? ? player.competition_1.first[1].to_i : 0 }.reverse
               end
  end

  # GET /players/1 or /players/1.json
  def show; end

  # GET /players/new
  def new
    @player = Player.new
  end

  # GET /players/1/edit
  def edit; end

  # POST /players or /players.json
  def create
    @player = Player.new(player_params)

    require 'httparty'
    @url = HTTParty.get(
      "https://secure.runescape.com/m=hiscore_oldschool/index_lite.ws?player=#{@player.name}",
      headers: { 'Content-Type' => 'application/json' }
    )

    call_osrs_api
    update_member_on_wom
    add_member_to_wom
    set_player_wom_id
    set_player_wom_name
    set_player_womrole

    @player.first_lvl = @player.lvl
    @player.first_xp = @player.xp
    @player.score = 0 if @player.score.nil?

    respond_to do |format|
      if @player.save
        format.html { redirect_to players_url, notice: 'Player was successfully created.' }
        format.json { render :show, status: :created, location: @player }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /players/1 or /players/1.json
  def update
    respond_to do |format|
      if @player.update(player_params)
        call_osrs_api
        set_player_wom_id
        set_player_wom_name
        set_player_womrole
        format.js {}
        format.html { redirect_to table_path, notice: 'Player was successfully updated.' }
        format.json { render :show, status: :ok, location: @player }
      else
        format.js {}
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /players/1 or /players/1.json
  def destroy
    if Rails.env.production? # Only allow deletion of players in production
      remove_member_from_wom
    else
      puts 'Skipping wom call'
    end
    @player.destroy

    respond_to do |format|
      format.html { redirect_to table_path, notice: 'Player was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def delete; end

  def reset; end

  def reset_siege_scores
    @players = Player.all
    @players.update_all(score: 0)
    redirect_to players_url, notice: 'Siege scores reset.'
  end

  def deactivate
    @player = Player.find(params[:id])
    @player.update(deactivated: true, deactivated_xp: @player.current_xp, deactivated_lvl: @player.current_lvl,
                   deactivated_date: Time.now)
    redirect_back(fallback_location: root_path)

    if Rails.env.production? # Only allow deletion of players in production
      remove_member_from_wom
    else
      puts 'Skipping wom call'
    end
  end

  def activate
    @player = Player.find(params[:id])

    call_osrs_api
    update_member_on_wom
    add_member_to_wom

    @player.update(deactivated: false, reactivated_xp: @player.current_xp, reactivated_lvl: @player.current_lvl,
                   reactivated_date: Time.now)
    redirect_back(fallback_location: root_path)
  end

  def call_osrs_api
    puts 'calling osrs api'
    require 'httparty'
    @url = HTTParty.get(
      "https://secure.runescape.com/m=hiscore_oldschool/index_lite.ws?player=#{@player.name}",
      headers: { 'Content-Type' => 'application/json' }
    )
    if @url.split("\n")[0].split(',').map(&:to_i).last.zero?
      puts 'Skipping osrs call' && return
    elsif @url.response.code == '404'
      @player.update(current_xp: 0)
      @player.update(current_lvl: 0)
      @player.update(clan_xp: 0)
      @player.update(clan_lvl: 0)
      format.html { redirect_to players_url, alert: 'Player was not found.' }
    else
      @player.xp = @url.split("\n")[0].split(',').map(&:to_i).last if @player.xp.nil?
      @player.lvl = @url.split("\n")[0].split(',').map(&:to_i).second if @player.lvl.nil?
      @player.update(current_xp: @url.split("\n")[0].split(',').map(&:to_i).last)
      @player.update(current_lvl: @url.split("\n")[0].split(',').map(&:to_i).second)
      puts "Updated #{@player.name}, current xp: #{@player.current_xp}, current lvl: #{@player.current_lvl}"
    end
  end

  def add_member_to_wom
    if !Rails.env.production?
      puts 'fake calling add_member_to_wom'
      nil
    else
      require 'net/http'
      require 'uri'
      require 'json'

      wom = Rails.application.credentials.dig(:wom, :verificationCode)
      uri = URI.parse('https://api.wiseoldman.net/v2/groups/2928/members')
      request = Net::HTTP::Post.new(uri)
      request.content_type = 'application/json'
      request.body = JSON.dump({
                                 'verificationCode' => wom,
                                 "members": [
                                   { username: @player.name,
                                     role: 'member' }
                                 ]
                               })

      req_options = {
        use_ssl: uri.scheme == 'https'
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      puts response.code
      puts response.body
    end
  end

  def update_member_on_wom
    require 'httparty'
    @url = HTTParty.post(
      "https://api.wiseoldman.net/v2/players/#{@player.name.gsub(' ', '%20')}",
      headers: { 'Content-Type' => 'application/json' }
    )

    if @url.response.code == '404'
      puts 'Player not found on wom'
    else
      puts 'Player found on wom'
    end
  end

  def remove_member_from_wom
    return unless Rails.env.production?

    require 'net/http'
    require 'uri'
    require 'json'

    wom = Rails.application.credentials.dig(:wom, :verificationCode)
    @player = Player.find(params[:id])
    uri = URI.parse('https://api.wiseoldman.net/v2/groups/2928/members')
    request = Net::HTTP::Delete.new(uri)
    request.content_type = 'application/json'
    request.body = JSON.dump({
                               'verificationCode' => wom,
                               "members": [@player.name]
                             })

    req_options = {
      use_ssl: uri.scheme == 'https'
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    puts response.code
    puts response.body
  end

  def update_rank
    @player.update(womrole: @player.clan_rank)
    redirect_back(fallback_location: root_path)
  end

  def add_siege_score
    new_score = @player.score ? @player.score + 2 : 2
    @player.update(score: new_score)
    redirect_back(fallback_location: root_path)
  end

  def switch_role
    @player.switch_role
    update_member_on_wom
    redirect_back(fallback_location: root_path)
  end

  def whitelist_runewatch
    username = params[:username].downcase
    player = Player.find_by("LOWER(name) = ?", username)
    
    # Debug output
    Rails.logger.info "Whitelisting player: #{username}"
    Rails.logger.info "Found player: #{player.inspect}" if player
    
    if player
      # Log before state
      Rails.logger.info "Before update: whitelisted=#{player.runewatch_whitelisted}, reported=#{player.runewatch_reported}"
      
      result = player.update(
        runewatch_whitelisted: true,
        runewatch_whitelist_reason: params[:reason],
        runewatch_whitelisted_at: Time.current
      )
      
      # Reload and log after state
      player.reload
      Rails.logger.info "Update result: #{result}"
      Rails.logger.info "After update: whitelisted=#{player.runewatch_whitelisted}, reported=#{player.runewatch_reported}"
      
      redirect_back fallback_location: table_path, notice: "#{player.name} has been whitelisted from RuneWatch alerts (whitelisted=#{player.runewatch_whitelisted})."
    else
      Rails.logger.info "Player not found: #{username}"
      redirect_back fallback_location: table_path, alert: "Player not found: #{username}"
    end
  end

  # method to run rake task to update clan members from api
  def update_players
    @players = Player.all
    Rake::Task['update_players'].invoke
    redirect_to players_url, notice: 'Players updating.'
  end

  def set_player_wom_id
    require 'httparty'
    name = url_encode(@player.name.strip)
  
    begin
      response = nil
      loop do
        response = HTTParty.get(
          "https://api.wiseoldman.net/v2/players/#{name}",
          headers: { 'Content-Type' => 'application/json' }
        )
  
        break unless response.code == 429
  
        puts "Rate limit exceeded, sleeping for 60 seconds"
        sleep(60)
      end
  
      @player.update(wom_id: response['id'])
      @player.update(ehb: response['ehb'])
      puts "Updated #{@player.name}, wom_id: #{@player.wom_id}"
    rescue StandardError => e
      puts "Error updating #{@player.name}, #{e}"
    end
  end

  def set_player_wom_name
    require 'httparty'
  
    begin
      response = nil
      loop do
        response = HTTParty.get(
          "https://api.wiseoldman.net/v2/players/id/#{@player.wom_id}",
          headers: { 'Content-Type' => 'application/json' }
        )
  
        break unless response.code == 429
  
        puts "Rate limit exceeded, sleeping for 60 seconds"
        sleep(60)
      end
  
      @player.update(wom_name: response['displayName'])
      puts "Updated #{@player.name}, wom_name: #{@player.wom_name}"
    rescue StandardError => e
      puts "Error updating #{@player.name}, #{e}"
    end
  end

  def set_player_womrole
    require 'httparty'
    require 'json'
    require 'erb'
  
    wom = Rails.application.credentials.dig(:wom, :verificationCode)
    api_key = Rails.application.credentials.dig(:wom, :apiKey)
    name = url_encode(@player.name.strip)
  
    begin
      response = nil
      loop do
        response = HTTParty.get(
          "https://api.wiseoldman.net/v2/players/#{name}/groups",
          headers: { 'Content-Type' => 'application/json', "x-api-key": api_key },
          data: { 'verificationCode' => wom }
        )
  
        break unless response.code == 429
  
        puts "Rate limit exceeded, sleeping for 60 seconds"
        sleep(60)
      end
  
      @hash = JSON.parse(response.body)
      if @hash.any?
        group = @hash.find { |g| g['groupId'] == 2928 }
        if group
          role = group['role']
          @player.update(womrole: role)
          puts "Updated #{@player.name}, womrole: #{@player.womrole}"
        else
          puts "No group data found for #{@player.name} in group 2928"
        end
      else
        puts "No group data found for #{@player.name}"
      end
    rescue StandardError => e
      puts "Error updating #{@player.name}, #{e}"
    end
  end

  def export
    @players = Player.where(deactivated: false)
    @players.to_csv

    respond_to do |format|
      format.csv { send_data @players.to_csv, filename: "players-#{Date.today}.csv" }
    end
  end

  private
  
  def fetch_reported_clan_members
    # Check against cached RuneWatch data
    cache_file = Rails.root.join('tmp', 'runewatch_cache.json')
    
    if File.exist?(cache_file)
      reported_users = Set.new(JSON.parse(File.read(cache_file)))
      
      # First, update the reported status for all players with IMPROVED MATCHING
      Player.where(deactivated: false).each do |player|
        # Normalize player name by removing all spaces
        normalized_name = player.name.downcase.gsub(/\s+/, '')
        
        # Check if this player's normalized name matches any reported normalized name
        is_reported = reported_users.any? do |reported|
          reported.downcase.gsub(/\s+/, '') == normalized_name
        end
        
        # Update the database if needed
        player.update_column(:runewatch_reported, is_reported) if player.runewatch_reported != is_reported
      end
      
      # Then, get ONLY players who are reported AND NOT whitelisted
      return Player.where(
        deactivated: false, 
        runewatch_reported: true,
        runewatch_whitelisted: false
      ).pluck(:name)
    end
    
    # Return empty array if no cache found
    []
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_player
    @player = Player.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def player_params
    params.require(:player).permit(:name, :xp, :lvl, :title, :rank, :current_xp, :current_lvl, :score, :wom_id,
                                   :wom_name, :inactive, :joined_date, :deactivated, :deactivated_xp, :deactivated_lvl,
                                   :siege_winner_place, :reactivated_xp, :reactivated_lvl, :womrole, :ehb)
  end
end
