Rails.application.routes.draw do
  get 'twilio' => 'webrtc_agents#index'
  get 'provision' => 'users#provision_twilio'
  get 'createacl' => 'users#provision_credential_list'
  get 'createipcl' => 'users#provision_ip_list'


  post 'incoming' => 'twilio#incoming'

  root to: 'visitors#index'
  devise_for :users, :controllers => { :registrations => "registrations" }
  resources :users
end
