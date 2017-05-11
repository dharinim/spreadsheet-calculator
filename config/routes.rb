Rails.application.routes.draw do
  root 'calculators#index'
  resources :calculators, only: [:new, :update, :index]
  post '/calculators', to: 'calculators#show_result'
end
