# Redirects the user to the provisioning process after registration
class RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    provision_path
  end
end
