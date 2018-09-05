Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get "about/alice"
  get "about/lispa"
  get "about/index"

  resources :rules do
    resources :rule_entries
  end

  get "ties/index"

  resources :detected_components
  resources :detections, :except => [:show]
  get 'detections/validate_components'
  post 'detections/acquire'
  post 'detections/remote_detect'
  post 'detections/remote_check'

  resources :components do
    get 'ties/select'
  end

  resources :uses
  resources :products
  post 'products/remote_create'

  resources :releases do
    get 'ties/select'
    get 'ties/edit'
    post 'ties/edit'
    get 'ties/show'
    get 'check'
    post 'update_check'
    get 'print'
    get 'print_check'
  end

  resources :license_types
  resources :categories
  resources :releases

  get "home/index"

  devise_for :admins
  devise_for :users

  resources :licenses do
    get 'download'
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root to: 'home#index'

end
