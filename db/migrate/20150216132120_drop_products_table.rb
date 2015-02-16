class DropProductsTable < ActiveRecord::Migration
  def up
    drop_table :webrtc_agents
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end