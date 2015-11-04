class AddDatetimeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :datetime, :time
  end
end
