require 'sequel'
require 'mysql2'
require_relative './so-config.rb'

DB = Sequel.connect({
	:adapter => 'mysql2',
	:host => $DB_HOST,
	:username => $DB_USER,
	:password => $DB_PASS,
	:database => $DB_NAME
})

class Tag < Sequel::Model(:Tag)
	dataset_module do
		def top_tags(site_id)
			where(:site => site_id).where("tag_name not like '%-count' and tag_name not like '%-rate'").limit(100)
		end

		def with_name(tag_name)
			where(:tag_name => tag_name).first
		end
	end

	# could maybe do this as an assoc, but I want to keep it as a dataset, and
	# not have the data actually cache, so it is better to do it the naive way
	def values
		TagValues.where(:tag_id => tag_id).reverse_order(:value_id).limit(1000)
	end

	def name
		tag_name.gsub "#{site}-tag-", ''
	end

	def link_html(options = {})
		css_class = options[:css_class]
		"<a href='#{tag_url}' class='#{css_class}'>#{Rack::Utils.escape_html name}</a>"
	end

	def tag_url
		URI.escape"/#{site}/#{name}"
	end

	def latest_value
		@latest_value ||= values.first
	end

end

class TagValues < Sequel::Model(:TagValue)
	def age
		Time.now - created_date
	end

	def previous
		@previous ||= TagValues.where(:tag_id => tag_id).
			where('value_id < ?', value_id).
			reverse_order(:value_id).
			first
	end

	def rate_per_sec
		(self.tag_value - previous.tag_value).to_f / (self.created_date - previous.created_date).to_f
	end

	def rate_per_hour
		rate_per_sec * 3600
	end

	def estimated_tag_value
		tag_value + rate_per_sec * age
	end

	def to_json(*args)
		self.values.merge({
			:age => self.age,
			:rate_per_sec => rate_per_sec
		}).to_json(*args)
	end
end

DB.disconnect