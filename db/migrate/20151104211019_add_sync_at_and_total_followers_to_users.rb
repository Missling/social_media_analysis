class AddSyncAtAndTotalFollowersToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sync_at, :time
    add_column :users, :total_followers, :integer
  end
end
