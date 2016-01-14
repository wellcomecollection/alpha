class LoggedInConstraint
  def matches?(request)
    return true if request.session[:user_id]
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

  resource :search, only: 'show', controller: 'search'

  resources :subjects, only: ['show'], controller: 'subjects_lookup'

  resources :things, only: ['show'], path: '', constraints: {id: /b[\dx]+/}

  resource :session, only: [:new, :create, :destroy]


  root 'home#show'

end
