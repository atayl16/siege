# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :set_event, only: %i[show edit update delete destroy]
  before_action :authenticate_user!, except: %i[index show gallery]
  before_action :store_location

  # GET /events or /events.json
  def index
    @events = Event.where('ends >= ?',
                          Time.now).order('ends ASC').all + Event.where('ends < ?', Time.now).order('ends DESC').all
  end

  # GET /events/1 or /events/1.json
  def show; end

  def gallery; end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit; end

  # POST /events or /events.json
  def create
    @event = Event.new(event_params)

    respond_to do |format|
      if @event.save
        format.html { redirect_to players_url, notice: 'Event was successfully created.' }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1 or /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to events_url, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1 or /events/1.json
  def destroy
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def event_params
    params.require(:event).permit(:wom_id, :name, :starts, :ends, :metric, :winner)
  end
end
