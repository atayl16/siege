# frozen_string_literal: true

json.extract! player, :id, :name, :xp, :lvl, :created_at, :updated_at
json.url player_url(player, format: :json)
