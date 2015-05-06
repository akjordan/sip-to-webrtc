# Provisions a phone number and SIP endpoint for a user
class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    redirect_to :back, alert: 'Access denied.' if current_user.id != 1
    @users = User.all
  end

  def provision_twilio
    rest_client = create_rest_client
    @number = provision_number(rest_client)

    @sipdomain = provision_domain(rest_client)

    @user = current_user.update_attributes(
      sip_domain: @sipdomain.domain_name,
      sip_domain_sid: @sipdomain.sid,
      phone_number: @number.phone_number)
    success('Twilio endpoints created')
  rescue StandardError => e
    failure("Twilio endpoints were not created: #{e}")
  end

  def provision_credential_list
    rest_client = create_rest_client
    credential_list = rest_client.account.sip.credential_lists
      .create(friendly_name: "#{current_user.email}")
    current_user.update_attributes(auth_acl: credential_list.sid)

    rest_client.account.sip.domains.get(current_user.sip_domain_sid)
      .credential_list_mappings.create(credential_list_sid: credential_list.sid)

    success('Twilio credential list created')
  rescue StandardError => e
    failure("Credential list failed: #{e}")
  end

  def provision_ip_list
    rest_client = create_rest_client
    ip_access_control_list = rest_client.account.sip.ip_access_control_lists
      .create(friendly_name: "#{current_user.email}")
    current_user.update_attributes(ip_acl: ip_access_control_list.sid)

    rest_client.account.sip.domains.get(current_user.sip_domain_sid)
      .ip_access_control_list_mappings
      .create(ip_access_control_list_sid: ip_access_control_list.sid)

    success('Twilio IP access control list created')
  rescue StandardError => e
    failure("IP access control list failed: #{e}")
  end

  def add_ip
    create_rest_client.account.sip.ip_access_control_lists
      .get(current_user.ip_acl)
      .ip_addresses.create(
        friendly_name: params[:friendlyname],
        ip_address: params[:ip])

    success('IP added to whitelist')
  rescue StandardError => e
    redirect_to webrtc_path,  alert: "IP failed: #{e}"
  end

  def add_user
    create_rest_client.account.sip.credential_lists
      .get(current_user.auth_acl)
      .credentials.create(
        username: params[:username],
        password: params[:password])

    success('User added to credential list')
  rescue StandardError => e
    failure("User failed: #{e}")
  end

  def delete_ip_list
    client = create_rest_client
    client.account.sip.domains.get(current_user.sip_domain_sid)
      .ip_access_control_list_mappings.get(current_user.ip_acl).delete
    client.account.sip.ip_access_control_lists.get(current_user.ip_acl).delete
    current_user.update_attributes(ip_acl: nil)

    success('IP access list deleted')
  rescue StandardError => e
    failure("Deleting IP access list failed: #{e}")
  end

  def delete_credential_list
    client = create_rest_client
    client.account.sip.domains.get(current_user.sip_domain_sid)
      .credential_list_mappings.get(current_user.auth_acl).delete
    client.account.sip.credential_lists.get(current_user.auth_acl).delete
    current_user.update_attributes(auth_acl: nil)

    success('Credential list deleted')
  rescue StandardError => e
    failure("Deleting credential list failed: #{e}")
  end

  def create_rest_client
    Twilio::REST::Client.new(
      Rails.application.secrets.twilio_account_sid,
      Rails.application.secrets.twilio_auth_token)
  end

  def success(message)
    redirect_to webrtc_path,  notice: message
  end

  def failure(message)
    redirect_to webrtc_path,  alert: message
  end

  def new_domain_string
    "#{Faker::Address.city}-#{Faker::Address.building_number}.sip.twilio.com"
      .downcase.gsub(/\s+/, '')
  end

  def provision_number(rest_client)
    rest_client.account.incoming_phone_numbers.create(
      area_code: '415',
      voice_url: Rails.application.secrets.twilio_twiml_callback_url,
      friendly_name: "#{current_user.email}'s Number")
  end

  def provision_domain(rest_client)
    rest_client.account.sip.domains.create(
      friendly_name: "#{current_user.email}'s SIP domain",
      voice_url: Rails.application.secrets.twilio_twiml_callback_url,
      domain_name: new_domain_string)
  end
end
