require 'sinatra'
require 'sinatra/json'
require 'sinatra/content_for'
require "sinatra/reloader" if development?

require 'json'
require 'erubis'
require 'pp'
require 'cgi'
require 'yaml'

$LOAD_PATH << './lib' << '../shared'

begin
	load './lib/so-db.rb'
rescue LoadError
	load '../shared/so-db.rb'
end

#set :raise_errors, false
#set :show_exceptions, true

set :version, '2.1'
set :erb, :escape_html => true

set :all_tag, 'all'
set :max_tags, 50
set :max_tags_default, 4

require 'sequel'
require 'mysql2'

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

	def estimated_tag_value
		tag_value + rate_per_sec * age
	end
end

get '/test' do
	json [
		Tag.with_name('so-question-count').latest_value.estimated_tag_value
	]
end

helpers do
	def load_json(path)
		return {} if ! File.exist? path
		JSON.parse File.read(path), :symbolize_names => true
	end

	def yearly_tag_data
		path = File.exist?('../yearly-tags.json') ? '../yearly-tags.json' : 'yearly-tags.json'
		@yearly_tag_data ||= load_json(path)
	end

	def site_list
		['so', 'sf', 'su']
	end

	def db_exec
		db = SoSql.real_connect
		yield(db) if block_given?
		db.close
	end

end

get '/?:cur_site?/' do |cur_site|
	cur_site ||= 'so'
	count_data = nil

	db_exec do |db|
		# its the front page. Get the three main counters.
		
		q_count = db.get_rate_from_rate("#{cur_site}-question")
		a_count = db.get_rate_from_rate("#{cur_site}-answer")
		c_count = db.get_rate_from_count("#{cur_site}-comment-count")
		count_data = [q_count, a_count, c_count]
	end

	erb :home, :layout => :_layout, :locals => {
		:count_data => count_data,
		:popular_tags => Tag.top_tags(cur_site).first(32),
		:so_tag => settings.all_tag,
		:cur_site => cur_site,
		:show_yearly_tag_data => (cur_site == 'so')
	}
end

get '/:cur_site/:so_tag/?' do |cur_site, so_tag|
	cur_site ||= 'so'
	so_tag ||= settings.all_tag
	return 'not found' if so_tag == 'apache'
	
	so_tag_display = so_tag

	# is this one of the main 3 tags? they get treated differently...
	if ['question', 'answer', 'comment'].include?(so_tag)
		question_count_tag = "#{cur_site}-#{so_tag}-count"
		tag_type = so_tag + 's'
		so_tag_display = so_tag + 's'
	else	
		question_count_tag = "#{cur_site}-tag-#{so_tag}"
		tag_type = 'questions'
	end

	q_count = nil

	db_exec do |db|
		q_count = db.get_rate_from_count(question_count_tag)
	end

	erb :tag, :layout => :_layout, :locals => {
		:count_data => [q_count],
		:popular_tags => Tag.top_tags(cur_site).first(32),
		:so_tag => so_tag,
		:so_tag_display => so_tag_display,
		:question_count_tag => question_count_tag,
		:tag_type => tag_type,
		:cur_site => cur_site
	}
end

def to_hourly(rate_data)
	if rate_data.nil?
		return nil;
	end

	return (rate_data['rate']*3600).round().to_s + ' / hr';
end

def to_daily(rate_data)
	if rate_data.nil?
		return nil;
	end

	return (rate_data['rate']*86400).round().to_s + ' / day';
end

def to_human_time(seconds)
	seconds = 0 if seconds.nil?
	(seconds / 60).round
end
