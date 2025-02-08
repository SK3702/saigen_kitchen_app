Rails.application.routes.draw do
  root 'home#index'
  devise_for :users, :controllers => {
    :registrations => 'users/registrations',
    :sessions => 'users/sessions',
    :passwords => 'users/passwords'
  }
  resources :profiles, only: [:show, :edit, :update]
  resources :recipes, except: [:index] do
    resources :comments, only: [:create, :destroy]
    resource :favorite, only: [:create, :destroy]
    get :favorites, on: :collection
    get :search, on: :collection
  end
  resources :categories, only: [:show]
end
