Rails.application.routes.draw do
  devise_for :users
  resources :players
  get 'players/:id/delete', to: 'players#delete', as: 'delete_player'

  root "players#index"
end
