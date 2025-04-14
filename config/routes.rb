# frozen_string_literal: true

Rails.application.routes.draw do
  resources :vars
  devise_for :users
  resources :players
  resources :events
  resources :achievements
  get 'players/:id/delete', to: 'players#deactivate', as: 'delete_player'
  get 'players/:id/activate', to: 'players#activate', as: 'activate_player'
  get 'export', to: 'players#export', as: 'export'
  get 'reset', to: 'players#reset', as: 'reset'
  get 'reset_siege_scores', to: 'players#reset_siege_scores', as: 'reset_siege_scores'
  get 'leaderboard', to: 'players#leaderboard', as: 'leaderboard'
  get 'events/:id/delete', to: 'events#delete', as: 'delete_event'
  get '/table', to: 'players#table', as: 'table'
  get '/deleted', to: 'players#deleted', as: 'deleted'
  get '/update_rank', to: 'players#update_rank', as: 'update_rank'
  get '/switch_role', to: 'players#switch_role', as: 'switch_role'
  get '/add_siege_score', to: 'players#add_siege_score', as: 'add_siege_score'
  get 'welcome', to: 'welcome#index', as: 'welcome'
  get '/gallery', to: 'events#gallery', as: 'gallery'
  get 'logo_var', to: 'vars#logo_var', as: 'logo_var'
  get 'hidden_players_var', to: 'vars#hidden_players_var', as: 'hidden_players_var'
  get 'competition_state_var', to: 'vars#competition_state_var', as: 'competition_state_var'
  get '/competition', to: 'players#competition', as: 'competition'
  post 'whitelist_runewatch', to: 'players#whitelist_runewatch'
  root 'welcome#index'
end
