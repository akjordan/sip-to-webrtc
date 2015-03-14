class WebrtcController < ApplicationController
  before_filter :authenticate_user!

  def index
    @agent = current_user
    @client = Twilio::REST::Client.new(Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token)

    if @agent.phone_number.nil? || @agent.sip_domain.nil?
      @number =  'agent not created'
      @domain = 'agent not created'
    else
      @number = @agent.phone_number
      @domain = @agent.sip_domain
    end

    if @agent.ip_acl.nil?
      @ip_acl_partial = "create_ipacl"
    else
      @ip_acl_partial = "ipacl"
      @ip_acl = @client.account.sip.ip_access_control_lists.get(@agent.ip_acl)
    end

    if @agent.auth_acl.nil?
      @acl_partial = "create_acl"
    else
      @acl_partial = "acl"
      @auth_acl = @client.account.sip.credential_lists.get(@agent.auth_acl) 
    end

    @agent_name = current_user.name

    capability = Twilio::Util::Capability.new Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token
    capability.allow_client_incoming current_user.id
   @token = capability.generate()
  end

end