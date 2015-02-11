Rails.application.routes.draw do
  resources :webrtc_agents

  get 'twilio' => 'twilio#index'
  root to: 'visitors#index'
  devise_for :users
  resources :users
end
