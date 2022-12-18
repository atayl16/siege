class PlayersController < ApplicationController
  before_action :set_player, only: %i[ show edit update destroy delete call_osrs_api ]

  # GET /players or /players.json
  def index
    @players = Player.all
    @clan = Player.where(title: nil).sort_by {|player| player.clan_xp }.reverse
    @officers = Player.where.not(title: nil).order(created_at: :asc)
  end

  # GET /players/1 or /players/1.json
  def show
  end

  # GET /players/new
  def new
    @player = Player.new
  end

  # GET /players/1/edit
  def edit
  end

  # POST /players or /players.json
  def create
    @player = Player.new(player_params)

    require 'httparty'
    @url = HTTParty.get(
      "https://secure.runescape.com/m=hiscore_oldschool/index_lite.ws?player=#{@player.name}",
      :headers =>{'Content-Type' => 'application/json'}
    )
    if @player.xp == nil then @player.xp = @url.split("\n")[0].split(",").map(&:to_i).last  end
    if @player.lvl == nil then @player.lvl = @url.split("\n")[0].split(",").map(&:to_i).second  end

    call_osrs_api
    add_member_to_wom

    respond_to do |format|
      if @player.save
        format.html { redirect_to players_url, notice: "Player was successfully created." }
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
        format.html { redirect_to players_url, notice: "Player was successfully updated." }
        format.json { render :show, status: :ok, location: @player }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /players/1 or /players/1.json
  def destroy
    @player.destroy

    respond_to do |format|
      format.html { redirect_to players_url, notice: "Player was successfully deleted." }
      format.json { head :no_content }
    end
  end

  def delete
    remove_member_from_wom
  end

  def call_osrs_api
    puts "calling osrs api"
    require 'httparty'
        @url = HTTParty.get(
          "https://secure.runescape.com/m=hiscore_oldschool/index_lite.ws?player=#{@player.name}",
          :headers =>{'Content-Type' => 'application/json'}
        )
        if @url.split("\n")[0].split(",").map(&:to_i).last == 0
          puts "Skipping osrs call" && return
        else
          @player.update( current_xp: @url.split("\n")[0].split(",").map(&:to_i).last )
          @player.update( current_lvl: @url.split("\n")[0].split(",").map(&:to_i).second )
          puts "Updated #{@player.name}, current xp: #{@player.current_xp}, current lvl: #{@player.current_lvl}"
        end
  end

  def add_member_to_wom
    require 'net/http'
    require 'uri'
    require 'json'

    wom = Rails.application.credentials.dig(:wom,:verificationCode)
    uri = URI.parse("https://api.wiseoldman.net/v2/groups/2928/members")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request.body = JSON.dump({
      "verificationCode" => wom,
      "members": [
        { username: @player.name,
          role: "member",
        }
      ]
    })

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    puts response.code
    puts response.body
  end

  def remove_member_from_wom
    require 'net/http'
    require 'uri'
    require 'json'

    wom = Rails.application.credentials.dig(:wom,:verificationCode)
    @player = Player.find(params[:id])
    uri = URI.parse("https://api.wiseoldman.net/v2/groups/2928/members")
    request = Net::HTTP::Delete.new(uri)
    request.content_type = "application/json"
    request.body = JSON.dump({
      "verificationCode" => wom,
      "members": [ @player.name ]
    })

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    puts response.code
    puts response.body
  end

  # method to run rake task to update clan members from api
  def update_players
    @players = Player.all
    Rake::Task['update_players'].invoke
    redirect_to players_url , notice: "Players updating."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_player
      @player = Player.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def player_params
      params.require(:player).permit(:name, :xp, :lvl, :title, :rank, :current_xp, :current_lvl)
    end
end
