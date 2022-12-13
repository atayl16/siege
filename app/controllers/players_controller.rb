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

    respond_to do |format|
      if @player.save
        format.html { redirect_to player_url(@player), notice: "Player was successfully created." }
        format.json { render :show, status: :created, location: @player }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /players/1 or /players/1.json
  def update

    call_osrs_api

    respond_to do |format|
      if @player.update(player_params)
        format.html { redirect_to player_url(@player), notice: "Player was successfully updated." }
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
  end

  def call_osrs_api
    require 'httparty'
    @url = HTTParty.get(
      "https://secure.runescape.com/m=hiscore_oldschool/index_lite.ws?player=#{@player.name}",
      :headers =>{'Content-Type' => 'application/json'}
    )
    @player.update( current_xp: @url.split("\n")[0].split(",").map(&:to_i).last )
    @player.update( current_lvl: @url.split("\n")[0].split(",").map(&:to_i).second )
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
