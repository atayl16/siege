Rails.application.routes.draw do
  devise_for :users
  resources :players
  get 'players/:id/delete', to: 'players#delete', as: 'delete_player'
  get 'players/update_players', to: 'players#update_players', as: 'update_players'

  root "players#index"
end
