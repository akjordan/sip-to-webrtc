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

  def new

    begin
      
      domain_string = "#{Faker::Address.city}-#{Faker::Address.building_number}-wrtc.sip.twilio.com".downcase.chomp

      client = Twilio::REST::Client.new(Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token)
      @number = client.account.incoming_phone_numbers.create( :area_code => '415',
       :voice_url => 'https://akjordan.ngrok.com/incoming', :friendly_name => "#{current_user.email}'s Number")

      @sipdomain = client.account.sip.domains.create(:friendly_name => "#{current_user.email}'s SIP domain",
      :voice_url => "https://akjordan.ngrok.com/incoming", :domain_name => domain_string)

    rescue Exception => e
      puts e
    end

    @webrtc_agent = current_user.build_webrtc_agent(sip_domain: @sipdomain.domain_name, phone_number: @number.phone_number)
    
    if @webrtc_agent.save
      redirect_to '/twilio',  notice: 'Webrtc agent was successfully created, maybe.'
    else
      redirect_to '/twilio',  notice: 'Something has gone terribly wrong'
    end

  end

  def incoming

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_webrtc_agent
      @webrtc_agent = WebrtcAgent.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def webrtc_agent_params
      params.require(:webrtc_agent).permit(:user_id, :sip_domain, :phone_number)
    end
end
