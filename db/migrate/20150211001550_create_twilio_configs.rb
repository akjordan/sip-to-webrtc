class CreateTwilioConfigs < ActiveRecord::Migration
  def change
    create_table :twilio_configs do |t|
      t.references :user, index: true
      t.string :sip_domain
      t.string :phone_number

      t.timestamps null: false
    end
    add_foreign_key :twilio_configs, :users
  end
end
