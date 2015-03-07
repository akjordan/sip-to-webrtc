class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @users = User.all
    unless current_user.id == 1
      redirect_to :back, :alert => "Access denied."
    end
  end
  
  def provision_twilio

    begin
      domain_string = "#{Faker::Address.city}-#{Faker::Address.building_number}-wrtc.sip.twilio.com".downcase.gsub(/\s+/, "")

      client = Twilio::REST::Client.new(Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token)
      @number = client.account.incoming_phone_numbers.create( :area_code => '415',
       :voice_url => Rails.application.secrets.twilio_twiml_callback_url, :friendly_name => "#{current_user.email}'s Number")

      @sipdomain = client.account.sip.domains.create(:friendly_name => "#{current_user.email}'s SIP domain",
      :voice_url => Rails.application.secrets.twilio_twiml_callback_url, :domain_name => domain_string)

      @user = current_user.update_attributes(sip_domain: @sipdomain.domain_name,
      sip_domain_sid: @sipdomain.sid, phone_number: @number.phone_number)

      redirect_to webrtc_path,  notice: 'Twilio endpoints were successfully provisioned!'
    rescue Exception => e
      redirect_to webrtc_path,  notice: "Provisioning failed for reason #{e}"
    end

  end

  def provision_credential_list
    begin

      client = Twilio::REST::Client.new(Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token)
      credential_list = client.account.sip.credential_lists.create(:friendly_name => "#{current_user.email}")
      current_user.update_attributes(:auth_acl => credential_list.sid )

      credential_list_mapping = client.account.sip.domains.get(current_user.sip_domain_sid)
      .credential_list_mappings.create(:credential_list_sid => credential_list.sid)

      redirect_to webrtc_path,  notice: 'Twilio credential_list created, and associated!'
    rescue Exception => e
      redirect_to webrtc_path,  notice: "Twilio credential_list ceation failed for reason #{e}"
    end
  end

  def provision_ip_list
    begin

      client = Twilio::REST::Client.new(Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token)
      ip_access_control_list = client.account.sip.ip_access_control_lists.create(:friendly_name => "#{current_user.email}")
      current_user.update_attributes(:ip_acl => ip_access_control_list.sid )

      ip_access_control_list_mapping = client.account.sip.domains.get(current_user.sip_domain_sid)
      .ip_access_control_list_mappings.create(:ip_access_control_list_sid => ip_access_control_list.sid)

      redirect_to webrtc_path,  notice: 'Twilio ip_access_control_list  created, and associated!'
    rescue Exception => e
      redirect_to webrtc_path,  notice: "Twilio ip_access_control_list ceation failed for reason #{e}"
    end
  end

  def add_ip
    begin

      client = Twilio::REST::Client.new(Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token)
      client.account.sip.ip_access_control_lists.get(current_user.ip_acl).ip_addresses.create(
      :friendly_name => params[:friendlyname], 
      :ip_address => params[:ip])

      redirect_to webrtc_path,  notice: 'IP added to whitelist!'
    rescue Exception => e
      redirect_to webrtc_path,  notice: "Adding an IP failed for reason #{e}"
    end
  end

  def add_user
    begin

      client = Twilio::REST::Client.new(Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token)
      client.account.sip.credential_lists.get(current_user.auth_acl).credentials.create(:username => params[:username] ,
      :password => params[:password])

      redirect_to webrtc_path,  notice: 'User added to credential list!'
    rescue Exception => e
      redirect_to webrtc_path,  notice: "Adding an user failed for reason #{e}"
    end
  end



end