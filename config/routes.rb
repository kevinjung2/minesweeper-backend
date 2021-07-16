Rails.application.routes.draw do
  resources :scores, only: [:index, :create]
  resources :users
  resources :cells, only: [:index, :show, :create]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
