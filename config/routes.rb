# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  resources :players
  get 'players/:id/delete', to: 'players#delete', as: 'delete_player'
  get '/table', to: 'players#table', as: 'table'
  get '/update_rank', to: 'players#update_rank', as: 'update_rank'

  root 'players#index'
end
