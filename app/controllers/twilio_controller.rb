class TwilioController < ApplicationController
  def index
    capability = Twilio::Util::Capability.new Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token
    capability.allow_client_incoming current_user.id
   @token = capability.generate()
  end
end
