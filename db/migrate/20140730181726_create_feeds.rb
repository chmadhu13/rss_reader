class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.string :site_url, :null => false
      t.string :title
      t.timestamps
    end
    
    add_index :feeds, :site_url, :unique => true
  end
end
