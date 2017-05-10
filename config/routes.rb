Rails.application.routes.draw do
  root 'calculators#index'
  resources :calculators
end
