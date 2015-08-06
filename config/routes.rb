Rails.application.routes.draw do


  resources :people_lookup, only: ['index'], controller: 'people_lookup'

  resources :people, only: ['show', 'index'], constraints: {id: /P\d+/}

  resources :people, only: ['show'], controller: 'people_lookup'

  resources :subjects, only: ['show', 'index']

  resources :things, only: ['show'], path: ''

  root 'home#show'

end
