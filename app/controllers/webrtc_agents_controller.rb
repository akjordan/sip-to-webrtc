class WebrtcAgentsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @webrtc_agent = current_user.webrtc_agent
    
    if @webrtc_agent.nil?
      @webrtc_number =  'agent not created'
      @webrtc_domain = 'agent not created'
    else
      @webrtc_number = @webrtc_agent.phone_number
      @webrtc_domain = @webrtc_agent.sip_domain
    end

    capability = Twilio::Util::Capability.new Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token
    capability.allow_client_incoming current_user.id
   @token = capability.generate()
  end
