# Extends application controller for SSL and redirect after sign in
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception

  force_ssl if: :ssl_configured?

  def ssl_configured?
    !Rails.env.development?
  end

  def after_sign_in_path_for(resource)
    webrtc_path
  end
end
