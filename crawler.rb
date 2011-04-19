require 'nokogiri'
require 'open-uri'
require 'uri'
require_relative 'data'

class Spider

	def crawl url

		if Page.count(:url => url) == 0
			page = Page.new
			page.url = url
			page.indexed = false
			page.domain =  get_domain(url)
			page.save
		else
			page = Page.first(:url => url)
		end
		
		if page.indexed == false
			# Find and parse links
			parse_links page

			# Index page contents
			index_page page
		end

		if Page.count(:domain => get_domain(url), :indexed => false)
			next_page = Page.first(:domain => get_domain(url), :indexed => false).url
		else
			next_page = Page.first(:indexed => false).url	
		end

		crawl next_page
	end

	private

	def get_domain url
		URI.parse(url).host.gsub(/^www\./, '')
	end

	def index_page page
		page.indexed = true
		page.save

		doc = Nokogiri::HTML(open(page.url))
	end

	def parse_links page
		doc = Nokogiri::HTML(open(page.url))
	
		doc.css('a').each do |link|
			queue_link link['href']
		end
	end

	def queue_link url
		unless (url =~ URI::regexp).nil?
			# Need to check if url exists already
			if Page.count(:url => url) == 0
				page = Page.new
				page.url = url
				page.indexed = false
				page.domain =  URI.parse(url).host.gsub(/^www\./, '')
				page.save
			end
		end
	end

end





spider = Spider.new

spider.crawl("http://www.dustinmartin.net/")
#spider.list_urls
#spider.list_domains
