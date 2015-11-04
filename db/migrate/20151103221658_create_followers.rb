class CreateFollowers < ActiveRecord::Migration
  def change
    create_table :followers do |t|
      t.references :user
      t.string :screen_name 
      t.integer :twitter_id
      t.integer :followers_count
      t.boolean :verified_follower, default: false

      t.timestamps null: false
    end
  end
end
