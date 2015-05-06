# This class handles routing incoming calls to the correct client ID
class TwilioController < ApplicationController
  include Webhookable

  after_filter :set_header

  skip_before_action :verify_authenticity_token

  def return_twiml
    client_name = find_client(params[:To])
    render_twiml generate_twiml(client_name)

    rescue StandardError => e
      puts "Error #{e} caught"
  end

  def find_client(number)
    if number.include? 'sip'
      to_sip = /[^@]+$/.match(number).to_s
      @agent = User.find_by sip_domain: to_sip
      client_name = @agent.id
    else
      @agent = User.find_by phone_number: number
      client_name = @agent.id
    end
    client_name
  end

  def generate_twiml(client_name)
    Twilio::TwiML::Response.new do |r|
      r.Dial do |d|
        d.Client client_name
      end
    end
  end
end
