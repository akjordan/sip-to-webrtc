Rails.application.routes.draw do
  get 'twilio' => 'webrtc_agents#index'
  root to: 'visitors#index'
  devise_for :users
  resources :users
end
