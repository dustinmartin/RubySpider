require 'data_mapper'
require  'dm-migrations'

TIMEOUT = 60 * 60 * 24 * 7 # 7 Days

class Page
	include DataMapper::Resource

	property :id,			Serial
	property :url,			String  
	property :domain,		String

	#property :crawl_count,	Integer

	property :created_at,	DateTime
	property :crawled_at,	DateTime

	# Find a page by it's URL
	def self.find url
		page = first(:url => url)
		page = new(:url => url) if page.nil?
		return page
	end

	# Get the next crawlable Page
	def self.next domain
		past_date = Time.now - TIMEOUT
		#domain = page.domain

		page = first(:domain => domain, :crawled_at => nil) 
		page = first(:domain => domain, :crawled_at.lte => date) if page.nil?
		page = first(:crawled_at => nil) if page.nil?
		page = first(:crawled_at.lte => date_range) if page.nil?
		#page = Page.first() if page == nil

		#page = Page.first(:crawled_at => nil) if page.nil?
		#page = Page.first(:crawled_at.lte => past_date) if page.nil?
		#page = Page.first() if page == nil

		if page.nil?
			throw "No page to crawl"
		end

		page
	end

	def url=(url)
		attribute_set(:url, url)
		attribute_set(:domain, get_domain(url))
	end

	private

	def get_domain url
		parsed_url = URI.parse(url)
		scheme = parsed_url.scheme
		domain = parsed_url.host.gsub(/^www\./, '')
	
		return "#{ scheme }://#{ domain }"
	end

end

#DataMapper::Logger.new($stdout, :debug)
#DataMapper.setup(:default, "sqlite:///#{Dir.pwd}/db/data.db")
 
 # A Postgres connection:
DataMapper.setup(:default, 'postgres://localhost/RubySpider')
DataMapper.auto_migrate!
DataMapper.finalize
