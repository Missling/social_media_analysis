class AddScreenNameAndTwitterIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :screen_name, :string
    add_column :users, :twitter_id, :string
  end
end
