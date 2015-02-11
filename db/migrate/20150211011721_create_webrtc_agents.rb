class CreateWebrtcAgents < ActiveRecord::Migration
  def change
    create_table :webrtc_agents do |t|
      t.references :user, index: true
      t.string :sip_domain
      t.string :phone_number

      t.timestamps null: false
    end
    add_foreign_key :webrtc_agents, :users
  end
end
