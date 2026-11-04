Rails.application.routes.draw do
  resource :session
  resource :registration, only: %i[ new create ]
  root "home#show"
end
