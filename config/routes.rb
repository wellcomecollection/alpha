Rails.application.routes.draw do


  resources :people, only: ['show', 'index']
  resources :subjects, only: ['show', 'index']

  resources :things, only: ['show'], path: ''

  root 'home#show'

end
