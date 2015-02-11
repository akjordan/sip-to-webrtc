class WebrtcAgentsController < ApplicationController
  before_action :set_webrtc_agent, only: [:show, :edit, :update, :destroy]

  def index
    @webrtc_agent = WebrtcAgent.find_by user_id: current_user.id
    capability = Twilio::Util::Capability.new Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token
    capability.allow_client_incoming current_user.id
   @token = capability.generate()
  end

  def new
    client = Twilio::REST::Client.new(Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token)
    @number = client.account.incoming_phone_numbers.create( :area_code => '415')

    @sipdomain = client.account.sip.domains.create(:friendly_name => "#{current_user.name} domain",
    :voice_url => "https://dundermifflin.example.com/twilio/app.php", :domain_name => "horrisdaipdomain.sip.twilio.com")

    @webrtc_agent = WebrtcAgent.new(sip_domain: @sipdomain.domain_name, phone_number: @number.phone_number, user_id: current_user.id)

    redirect_to '/twilio',  notice: 'Webrtc agent was successfully created, maybe.'

  end

  def destroy
    @webrtc_agent.destroy
    respond_to do |format|
      format.html { redirect_to webrtc_agents_url, notice: 'Webrtc agent was successfully destroyed.' }
      format.json { head :no_content }
    end
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
