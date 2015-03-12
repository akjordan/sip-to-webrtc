Rails.application.routes.draw do
  root to: 'visitors#index'

  get 'webrtc' => 'webrtc#index'
  get 'provision' => 'users#provision_twilio'
  get 'createacl' => 'users#provision_credential_list'
  get 'createipcl' => 'users#provision_ip_list'
  get 'deleteipacl' => 'users#delete_ip_list'
  get 'deleteacl' => 'users#delete_credential_list'

  post 'adduser' => 'users#add_user'
  post 'addip' => 'users#add_ip'
  post 'incoming' => 'twilio#incoming'

  devise_for :users, :controllers => { :registrations => "registrations" }
  resources :users
end