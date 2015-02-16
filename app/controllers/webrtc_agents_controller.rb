class WebrtcAgentsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @agent = current_user

    if @agent.phone_number.nil? || @agent.sip_domain.nil?
      @number =  'agent not created'
      @domain = 'agent not created'
    else
      @number = @agent.phone_number
      @domain = @agent.sip_domain
    end

    capability = Twilio::Util::Capability.new Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token
    capability.allow_client_incoming current_user.id
   @token = capability.generate()
  end

end