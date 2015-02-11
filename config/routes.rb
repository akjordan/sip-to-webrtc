Rails.application.routes.draw do
  get 'twilio' => 'webrtc_agents#index'
  get 'webrtc' => 'webrtc_agents#new'
  root to: 'visitors#index'
  devise_for :users
  resources :users
end
