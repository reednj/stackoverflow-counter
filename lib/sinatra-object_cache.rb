
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

class App
	def main
		oc = ObjectCache.new
		loop do
			puts oc.cache('1234', :ttl => 10) { 
				sleep(2)
				Time.now.to_s
			} 

			sleep 0.5
		end
	end
end

App.new.main
