# Provisions a phone number and SIP endpoint for a user
class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    redirect_to :back, alert: 'Access denied.' if current_user.id != 1
    @users = User.all
  end

  def provision_twilio
    begin
      domain_string = "#{Faker::Address.city}-#{Faker::Address.building_number}.sip.twilio.com".downcase.gsub(/\s+/, "")

      client = Twilio::REST::Client.new(Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token)
      @number = client.account.incoming_phone_numbers.create(
        area_code: '415',
        voice_url: Rails.application.secrets.twilio_twiml_callback_url,
        friendly_name: "#{current_user.email}'s Number")

      @sipdomain = client.account.sip.domains.create(
        friendly_name: "#{current_user.email}'s SIP domain",
        voice_url: Rails.application.secrets.twilio_twiml_callback_url,
        domain_name: domain_string)

      @user = current_user.update_attributes(
        sip_domain: @sipdomain.domain_name,
        sip_domain_sid: @sipdomain.sid,
        phone_number: @number.phone_number)
      redirect_to webrtc_path,  notice: 'Twilio endpoints created'
    rescue StandardError => e
      redirect_to webrtc_path,  alert: "Twilio endpoints were not created: #{e}"
    end
  end

  def provision_credential_list
    begin
      client = Twilio::REST::Client.new(Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token)
      credential_list = client.account.sip.credential_lists.create(friendly_name: "#{current_user.email}")
      current_user.update_attributes(auth_acl: credential_list.sid )

      credential_list_mapping = client.account.sip.domains.get(current_user.sip_domain_sid)
      .credential_list_mappings.create(credential_list_sid: credential_list.sid)

      redirect_to webrtc_path,  notice: 'Twilio credential list created'
    rescue StandardError => e
      redirect_to webrtc_path,  alert: "Credential list failed: #{e}"
    end
  end

  def provision_ip_list
    begin
      client = Twilio::REST::Client.new(Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token)
      ip_access_control_list = client.account.sip.ip_access_control_lists.create(friendly_name: "#{current_user.email}")
      current_user.update_attributes(ip_acl: ip_access_control_list.sid )

      ip_access_control_list_mapping = client.account.sip.domains.get(current_user.sip_domain_sid)
      .ip_access_control_list_mappings.create(ip_access_control_list_sid: ip_access_control_list.sid)

      redirect_to webrtc_path,  notice: 'Twilio IP access control list created'
    rescue StandardError => e
      redirect_to webrtc_path,  alert: "IP access control list failed: #{e}"
    end
  end

  def add_ip
    begin
      client = Twilio::REST::Client.new(Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token)
      client.account.sip.ip_access_control_lists.get(current_user.ip_acl).ip_addresses.create(
      friendly_name: params[:friendlyname], 
      ip_address: params[:ip])

      redirect_to webrtc_path,  notice: 'IP added to whitelist'
    rescue StandardError => e
      redirect_to webrtc_path,  alert: "IP failed: #{e}"
    end
  end

  def add_user
    begin
      client = Twilio::REST::Client.new(Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token)
      client.account.sip.credential_lists.get(current_user.auth_acl).credentials.create(username: params[:username] ,
      password: params[:password])

      redirect_to webrtc_path,  notice: 'User added to credential list'
    rescue StandardError => e
      redirect_to webrtc_path,  alert: "User failed: #{e}"
    end
  end

    def delete_ip_list
    begin
      client = Twilio::REST::Client.new(Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token)
      client.account.sip.domains.get(current_user.sip_domain_sid).ip_access_control_list_mappings.get(current_user.ip_acl).delete()
      client.account.sip.ip_access_control_lists.get(current_user.ip_acl).delete()
      current_user.update_attributes(ip_acl: nil )

      redirect_to webrtc_path,  notice: 'IP access list deleted'
    rescue StandardError => e
      redirect_to webrtc_path,  alert: "Deleting IP access list failed: #{e}"
    end
  end

      def delete_credential_list
    begin
      client = Twilio::REST::Client.new(Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token)
      client.account.sip.domains.get(current_user.sip_domain_sid).credential_list_mappings.get(current_user.auth_acl).delete()
      client.account.sip.credential_lists.get(current_user.auth_acl).delete()
      current_user.update_attributes(auth_acl: nil )

      redirect_to webrtc_path,  notice: 'Credential list deleted'
    rescue StandardError => e
      redirect_to webrtc_path,  alert: "Deleting credential list failed: #{e}"
    end
  end
end
