class FeedsController < ApplicationController
  def index
    @feeds = Feed.all
  end
  
  def show
    @feed = Feed.where(:id => params[:id]).first
    @posts = RssFeedReader.fetch_posts(@feed.site_url)[:posts] if @feed
  end
  
  def new
    @feed = Feed.new
  end
  
  def create
    rss_feed = RssFeedReader.fetch_posts(params[:feed][:site_url])
    if rss_feed[:feed_info].blank?
      flash[:error] = 'Oops! You entered wrong url. Please enter correct url'
      render action: "new" and return
    end
    
    @feed = Feed.create_update_feed(:site_url => params[:feed][:site_url], :title => rss_feed[:feed_info][:title]) do |params|
              feed = Feed.create!(:site_url => params[:site_url], :title => params[:title])
            end
    
    if @feed[:err].present?
      flash[:error] = @feed[:err]
      @feed = Feed.new(:site_url => params[:feed][:site_url])
      render action: "new" and return
    end
    redirect_to action: 'index'
  end
  
  def edit
    @feed = Feed.where(:id => params[:id]).first
  end
  
  def update
    rss_feed = RssFeedReader.fetch_posts(params[:feed][:site_url])
    if rss_feed[:feed_info].blank?
      @feed = Feed.where(:id => params[:id]).first
      @feed.site_url = params[:feed][:site_url]
      flash[:error] = 'Oops! You entered wrong url. Please enter correct url'
      render action: "edit" and return
    end
    feed = Feed.create_update_feed(:site_url => params[:feed][:site_url], :title => rss_feed[:feed_info][:title], :id => params[:id]) do |params|
             feed = Feed.update(params[:id], {:site_url => params[:site_url], :title => params[:title]})
           end
    if feed[:err].blank?
      flash[:success] = 'Hurry! Your feed got successfully updated'
    else
      @feed = Feed.where(:id => params[:id]).first
      @feed.site_url = params[:feed][:site_url]
      flash[:error] = feed[:err]
      render action: "edit" and return
    end
    redirect_to action: 'index'
  end
  
  def destroy
    feed = Feed.destroy(params[:id])
    flash[:success] = 'Hurry! Your feed got successfully deleted' if feed
    redirect_to action: 'index'
  end
  
  def all_posts
    @indexed_feeds = Feed.all.index_by(&:id)
    
    @timebased_feeds = RssFeedReader.multi_feeds_posts(@indexed_feeds)
  end
end
