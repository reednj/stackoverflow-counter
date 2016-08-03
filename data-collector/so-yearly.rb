#!/usr/bin/ruby

$LOAD_PATH << './lib' << '../shared'

require 'rubygems'
require 'time'
require 'mysql2'
require 'sequel'
require 'json'

require 'so-config'

class App
	def main
		data = get_top_tags_for_year(2015)
		
	end

	def db
		@db ||= Sequel.connect({
			:adapter => 'mysql2',
			:host => $DB_HOST,
			:username => $DB_USER,
			:password => $DB_PASS,
			:database => $DB_NAME
		})
	end

	def load_json(path)
		JSON.parse File.read(path), :symbolize_names => true
	end

	def get_top_tags_for_year(year)
		start_date = Time.new(year, 1, 1)
		end_date = Time.new(year + 1, 1, 1)

		query = "select 
			t.tag_name,
			t.description,
			(max(tag_value) - min(tag_value)) as tag_value_delta
		from TagValue tv
			inner join Tag t
				on t.tag_id = tv.tag_id
		where tv.created_date >= ?
			and tv.created_date < ?
			and t.tag_name not like '%-count'
		group by t.tag_name, t.description
		order by (max(tag_value) - min(tag_value)) desc
		limit 20"

		db[query, start_date, end_date].all
	end
end

class Hash
	def save_json(path)
		File.open(path, 'w') { |file| file.write self.to_json }
	end
end

class Array
	def save_json(path)
		File.open(path, 'w') { |file| file.write self.to_json }
	end
end

App.new.main
