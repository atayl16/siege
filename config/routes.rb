# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  resources :players
  resources :events
  get 'players/:id/delete', to: 'players#delete', as: 'delete_player'
  get 'leaderboard', to: 'players#leaderboard', as: 'leaderboard'
  get 'events/:id/delete', to: 'events#delete', as: 'delete_event'
  get '/table', to: 'players#table', as: 'table'
  get '/update_rank', to: 'players#update_rank', as: 'update_rank'
  get 'welcome', to: 'welcome#index', as: 'welcome'
  get '/gallery', to: 'events#gallery', as: 'gallery'

  root 'welcome#index'
end
