class AddTwiliotoUsers < ActiveRecord::Migration
  def change
        add_column :users, :sip_domain, :string
        add_column :users, :phone_number, :string
        add_column :users, :ip_acl, :string
        add_column :users, :auth_acl, :string
  end
end
