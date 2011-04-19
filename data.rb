require 'data_mapper'
require  'dm-migrations'

=begin
class Domain
	include DataMapper::Resource

	property :id,			Serial
	property :url,			String
	property :created_at,	DateTime 
	property :updated_at,	DateTime 	
end
=end

class Page
	include DataMapper::Resource

	property :id,			Serial
	property :title,		String   
	property :url,			String   
	property :domain,		String
	property :created_at,	DateTime
	property :updated_at,	DateTime
	property :indexed,		Boolean

	has n, :words, :through => Resource
end

class Word
	include DataMapper::Resource

	property :id,			Serial
	property :word,			String   
	property :created_at,	DateTime 

	has n, :pages, :through => Resource
end

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite:///#{Dir.pwd}/db/data.db")
DataMapper.auto_migrate!
DataMapper.finalize
