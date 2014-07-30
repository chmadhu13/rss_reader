class Feed < ActiveRecord::Base
  validates :site_url, presence: true
  validates :title, presence: true
  
  def self.create_update_feed(params)
    feed = yield(params) if block_given?
    
    return {err: nil, :feed => feed}
  rescue Exception => e
    puts "=====Exception => #{e.to_s} &&& #{e.inspect} &&& #{e.backtrace}"
    return {:err => 'Oops! This Feed is already registered. Please try another'} if /Mysql2::Error: Duplicate entry/.match(e.to_s)
    return {:err => 'Oops! Something went wrong. Please try again later'}
  end
  
end
