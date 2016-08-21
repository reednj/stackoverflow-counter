require 'digest/sha1'

#
# ObjectCache
#
# This is a simple in process memory cache designed to be used with
# Rack/sinatra for caching request data. It is not very efficient, as
# nothing is shared between the processes, so if it is running on passenger
# each process will have its own cache. However, I think it makes up for this
# with simplicity, so if the underlying request doesn't take too long, and not
# much is being stored, its probably worth going with this over a more
# complicated solution.
#
# Usage:
#
#     # without the sinatra helper
#     obj_cache = ObjectCache.new
#     ...
#
#     obj_cache.cache 'home_page_data', :ttl => 5.minutes do
#         # do some slow stuff
#     end
#
#    # with the sinatra helper - the key will be generated
#    # from the request object
#    cache_object :for => 5.minutes { ... }
#
class ObjectCache
	attr_accessor :items

	def initialize
		self.items = {}
	end

	def cache(key, options = {})
		raise 'block required' if !block_given?
		self.add(key, yield, options) if !valid?(key)
		return get(key).data
	end

	def add(key, data, options = {})
		self.items[key] = ObjectCacheItem.new(data, options)
	end

	def get(key)
		if self.valid? key
			return self.items[key]
		else
			return nil
		end
	end

	def valid?(key)
		include?(key) && !self.items[key].expired?
	end

	def include?(key)
		self.items.include? key
	end
end


# we could actually make this a bit more generic, more of a protocol / mixin
# type thing, so that it could store really any sort of data. I _think_ the only
# required methods would be +expired?+, +data+ and +data=+, with the rest depending
# on the underlying store
class ObjectCacheItem
	attr_accessor :created_date
	attr_accessor :ttl
	attr_accessor :data

	def initialize(data, options = {})
		self.created_date = Time.now
		self.ttl = options[:ttl] || 60.0
		self.data = data
	end

	def expiry_date
		self.created_date + self.ttl
	end

	def expired?
		Time.now > self.expiry_date
	end
end

if defined? Sinatra::Application
	OBJECT_CACHE = ObjectCache.new

	helpers do
		def cache_object(options = {}, &block)
			key = request.url.sha1
			options[:ttl] = options[:ttl] || options[:for] || 60.0
			OBJECT_CACHE.cache(key, options, &block)
		end
	end
end

class String
	def sha1
		Digest::SHA1.hexdigest self
	end
end

