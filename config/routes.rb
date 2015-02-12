Rails.application.routes.draw do
  get 'twilio' => 'webrtc_agents#index'
  get 'new' => 'webrtc_agents#new'
  post 'incoming' => 'twilio#incoming'

  root to: 'visitors#index'
  devise_for :users
  resources :users
end
