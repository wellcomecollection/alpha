Rails.application.routes.draw do

  resources :users, only: [:index, :create, :new]


  resources :people_lookup, only: ['index'], controller: 'people_lookup'

  resources :people, only: ['show', 'index', 'edit'], constraints: {id: /P\d+/}

  resources :people, only: ['show'], controller: 'people_lookup'

  resources :subjects_lookup, only: ['index'], controller: 'subjects_lookup'
  resources :subjects, only: ['show', 'index'], constraints: {id: /S\d+/}
  resources :subjects, only: ['show'], controller: 'subjects_lookup'

  resources :things, only: ['show'], path: ''

  resource :session, only: [:new, :create, :destroy]

  root 'home#show'

end
