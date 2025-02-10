Rails.application.routes.draw do
  get 'contacts/new'
  get 'contacts/create'
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
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_scope :user do
    post 'users/guest_log_in', to: 'users/sessions#guest_log_in'
  end
  resources :contacts, only: [:new, :create] do
    collection do
        post 'confirm'
        post 'back'
    end
  end
end
