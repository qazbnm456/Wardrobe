Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users, controllers: {confirmations: "confirmations" }
  match '/user/:id', to: 'users#show', via: 'get', as: :show_user

  mount StatusPage::Engine =>'/'
  root 'index#index'

  match 'store', to: 'index#store', via: 'get'
  match 'about', to: 'index#about', via: 'get'

  # docker
  # match 'updateAllImages', to: 'docker#updateAllImages', via: 'get'
  match 'getAllImages', to: 'docker#getAllImages', via: 'post'
  match 'getUserImages', to: 'docker#getUserImages', via: 'post'
  match 'assignToUser', to: 'docker#assignToUser', via: 'post'
  match 'spawnInstance', to: 'docker#spawnInstance', via: 'post'
end
