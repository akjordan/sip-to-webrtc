Rails.application.routes.draw do
  get 'twilio' => 'twilio#index'
  root to: 'visitors#index'
  devise_for :users
  resources :users
end
