class LoggedInConstraint
  def matches?(request)
    request.cookie_jar.encrypted[:user_id].present?
  end
end

Rails.application.routes.draw do

  require 'sidekiq/web'

  mount Sidekiq::Web => '/sidekiq', constraints: LoggedInConstraint.new

  resources :users, only: [:index, :create, :new]

  resource :about, only: 'show', controller: 'pages', id: 'about'

  resources :people_lookup, only: ['index'], controller: 'people_lookup'

  resources :people, only: ['show', 'index', 'edit', 'update'], constraints: {id: /P\d+/} do

    resource :editorial, only: ['show', 'update'], controller: 'people_editorial'
    resource :intro, only: ['show', 'update'], controller: 'people_intro'
    resource :wikipedia, only: ['update'], controller: 'people_wikipedia'
  end

  resource :recent_changes, only: ['show'], controller: 'recent_changes'

  resources :people, only: ['show'], controller: 'people_lookup'

  resources :subjects_lookup, only: ['index'], controller: 'subjects_lookup'

  resources :subjects, only: ['show', 'index', 'update'], constraints: {id: /S\d+/} do
    resource :intro, only: ['show', 'update'], controller: 'subjects_intro'
    member do
      get ':year', action: :show, as: :year
    end
  end

  resources :person_as_subjects, only: 'show', constraints: {id: /P\d+/}, path: 'subjects', controller: 'people_as_subjects'

  resources :subjects, only: 'show', constraints: {id: /S\d+\+S\d+/}, controller: 'subjects', action: 'multiple', as: 'multiple_subjects'

  resource :types_search, only: 'show', path: 'types/search', controller: 'types_search'

  resources :types, only: ['index', 'show', 'update'] do
    resources :subjects, only: ['index', 'show'], controller: 'type_subjects', constraints: {id: /S\d+/}
    resources :people, only: ['index', 'show'], controller: 'type_people', constraints: {id: /P\d+/}
  end

  resource :collections_search, only: 'show', path: 'collections/search', controller: 'collections_search'

  resource :collections_all, only: 'show', path: 'collections/all', controller: 'collections', action: 'all', as: 'all_collections'

  resources :collections, only: ['index', 'show', 'edit', 'update', 'new', 'create'], constraints: {id: /[^\/]+/} do
    resource :status, only: 'update', controller: 'collections', action: 'status'
    resource :editorial, only: ['show', 'update'], controller: 'collections_editorial'
    resources :subjects, only: ['index', 'show'], controller: 'collection_subjects', constraints: {id: /S\d+/}
    resources :people, only: ['index', 'show'], controller: 'collection_people', constraints: {id: /P\d+/}
    resources :types, only: ['index', 'show'], controller: 'collection_types', constraints: {id: /T\d+/}
  end

  resource :newly_digitized, only: 'show', controller: 'newly_digitized'

  resource :search, only: 'show', controller: 'search'

  resources :subjects, only: ['show'], controller: 'subjects_lookup'

  resources :things, only: ['show'], path: '', constraints: {id: /b[\dx]+/} do
    resources :pages, only: ['index', 'show'], constraints: {id: /\d+/}, controller: 'record_pages'
  end

  resource :session, only: [:new, :create, :destroy]


  root 'home#show'

  match '*any', via: :all, to: 'errors#not_found'
end
