json.array!(@webrtc_agents) do |webrtc_agent|
  json.extract! webrtc_agent, :id, :user_id, :sip_domain, :phone_number
  json.url webrtc_agent_url(webrtc_agent, format: :json)
end
