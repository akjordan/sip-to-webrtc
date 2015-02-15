class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @users = User.all
  end

  def show
   @user = User.find(params[:id])
    unless @user == current_user
      redirect_to :back, :alert => "Access denied."
    end
  end

  def provision_twilio

    begin
      domain_string = "#{Faker::Address.city}-#{Faker::Address.building_number}-wrtc.sip.twilio.com".downcase.gsub(/\s+/, "")

      client = Twilio::REST::Client.new(Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token)
      @number = client.account.incoming_phone_numbers.create( :area_code => '415',
       :voice_url => "https://akjordan.ngrok.com/incoming", :friendly_name => "#{current_user.email}'s Number")

      @sipdomain = client.account.sip.domains.create(:friendly_name => "#{current_user.email}'s SIP domain",
      :voice_url => "https://akjordan.ngrok.com/incoming", :domain_name => domain_string)

    rescue Exception => e
      puts "Failure during account provisioning #{e}"
    end

    @user = current_user.(sip_domain: @sipdomain.domain_name, phone_number: @number.phone_number)
    if @user.save
      redirect_to '/twilio',  notice: 'Twilio endpoints were successfully provisioned!'
    else
      redirect_to '/twilio',  notice: 'Something has gone terribly wrong!'
    end

  end

end
