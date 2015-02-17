class AddsipdomainsidtoUsers < ActiveRecord::Migration
  def change
        add_column :users, :sip_domain_sid, :string
  end
end
