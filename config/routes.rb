Rails.application.routes.draw do
  get 'favorites/create'
  get 'favorites/destroy'
  root 'home#index'
  devise_for :users, :controllers => {
    :registrations => 'users/registrations',
    :sessions => 'users/sessions',
    :passwords => 'users/passwords'
  }
  resources :profiles, only: [:show, :edit, :update]
  resources :recipes, except: [:index] do
    resources :comments, only: [:create, :edit, :update, :destroy]
    resource :favorite, only: [:create, :destroy]
    get :favorites, on: :collection
  end
  resources :categories, only: [:show]
end
