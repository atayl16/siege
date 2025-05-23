# frozen_string_literal: true

Rails.application.routes.draw do
  # Only keep these two routes
  get 'redirect_notice', to: 'welcome#redirect_notice'
  get 'staying', to: 'application#staying'
  
  # Redirect everything else to the redirect notice
  match '*path', to: 'welcome#redirect_notice', via: :all
  root 'welcome#redirect_notice'
end
