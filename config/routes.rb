Rails.application.routes.draw do
  resource :session
  resource :registration, only: %i[ new create ]
  resources :rooms, only: %i[ index show ] do
    resources :messages, only: %i[ index create ]
  end
  root "rooms#index"
end
