class RssFeedReader
  
  def self.fetch_posts(url)
    require 'rss'
    rss_feed = {posts: [], feed_info: {}}
    begin
      rss = RSS::Parser.parse(url, false)
      rss_feed[:feed_info][:title] = rss.channel.title
      rss.items.each do |item|
        rss_feed[:posts] << {title: item.title, description: item.description, link: item.link}
      end
    rescue Exception => e
      puts "Exception => #{e.to_s} #{e.inspect}"
    end  
    rss_feed
  end
  
  def self.multi_feeds_posts(indexed_feeds)
    require 'rss'
    timebased_feeds = {}
    indexed_feeds.each do |id, feed|
      rss_feed = {posts: [], feed_info: {}}
      begin
        rss = RSS::Parser.parse(feed.site_url, false)
        rss.items.each do |item|
          timebased_feeds[item.pubDate.to_i] ||= []
          timebased_feeds[item.pubDate.to_i] << {title: item.title, description: item.description, link: item.link, feed_id: id}
        end
      rescue Exception => e
        puts "Exception => #{e.to_s} #{e.inspect}"
      end
      rss_feed
    end
    timebased_feeds
  end
end