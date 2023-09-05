# frozen_string_literal: true

class AchievementsController < ApplicationController
  before_action :store_location

  def index
    @achievements = Achievement.all
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_achievement
    @achievement = Event.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def achievement_params
    params.require(:achievement).permit(:wom_id, :name, :date, :player_name)
  end
end
