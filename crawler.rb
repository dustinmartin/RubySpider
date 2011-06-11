require 'nokogiri'
require 'open-uri'
require 'uri'
require_relative 'data'

DO_NOT_CRAWL_TYPES = %w(.pdf .doc .xls .ppt .mp3 .m4v .avi .mpg .rss .xml .json .txt .git .zip .md5 .asc .jpg .gif .png)

class Spider

	# Seed DB with URL
	def seed url
		page = Page.new
		page.url = url
		page.save
	end

	def start
		domain = Page.first.domain

		loop do
			begin
				page = Page.next domain

				puts "Processing #{page.url}"
				
				crawl page

				domain = page.domain
			rescue => e 
				puts "** Error encountered crawling - #{page.url} - #{e.to_s}"
				exit
			end
		end
	end

	private

	def crawl page
		page.crawled_at = Time.now

		parse page

		page.save
	end

	def queue url
		page = Page.find url
		page.save
	end

	def parse page
		# Get the URL for the current page
		url = page.url

		# Get the domain from the current page
		domain = page.domain

		begin
			# Open the URL and parse
			doc = Nokogiri::HTML(open(url))

			# Loop through all the links and queue them up
			doc.css('a').each do |link|
				
				# Verify that the link is valid
				if link['href'] =~ URI::regexp
					
					# Check if the link is absolute
					url = normalize(link['href'], domain)
					
					# Queue up the link
					queue URI.escape(url)
				end
			end	
		rescue => e
			puts "** Error parsing links at url - #{page.url} - #{e.to_s}"
		end
	end

	def absolute? url
		URI.parse(url).absolute?
	end

	def normalize url, domain
		if not absolute? url
			normalized_url = (URI.parse(domain) + url).to_s
		else
			normalized_url = url
		end

		normalized_url.sub(/(\/)+$/,'')
	end

end


spider = Spider.new

spider.seed("http://en.wikipedia.org/wiki/Main_Page")
spider.seed("http://www.dustinmartin.net")
spider.start
