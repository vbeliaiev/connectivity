Rails.application.routes.draw do
  devise_for :users, skip: [:registrations, :confirmations], controllers: {
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  }
  as :user do
    get 'users/edit' => 'users/registrations#edit', as: :edit_user_registration
    put 'users' => 'users/registrations#update', as: :user_registration
  end
  resources :folders, except: [:index]
  resources :articles
  resources :pdf_notes, only: %i[new create show destroy]
  resources :video_notes, only: %i[new create show destroy]
  resources :photo_galleries, only: %i[new create show edit update destroy]

  resources :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "home#index"
end
