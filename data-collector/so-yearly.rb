#!/usr/bin/ruby

$LOAD_PATH << './lib' << '../shared'

require 'rubygems'
require 'time'
require 'so-db'

class App
	def main
		@db = SoSql.real_connect()
		data = get_top_tags_for_year(2015)
		puts data
	end

	def get_top_tags_for_year(year)
		start_date = Time.new year, 1, 1
		end_date = Time.new year+1, 1, 1
		query = "select 
			t.tag_name,
			t.description,
			(max(tag_value) - min(tag_value)) as tag_value_delta
		from TagValue tv
			inner join Tag t
				on t.tag_id = tv.tag_id
		where tv.created_date >= '#{start_date.iso8601}'
			and tv.created_date < '#{end_date.iso8601}'
			and t.tag_name not like '%-count'
		group by t.tag_name, t.description
		order by (max(tag_value) - min(tag_value)) desc
		limit 20"		
	end
end

App.new.main
