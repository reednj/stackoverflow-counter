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

set :version, '1.0'
set :erb, :escape_html => true

set :all_tag, 'all'
set :max_tags, 50
set :max_tags_default, 4

DB = SoSql.real_connect;

helpers do
	def load_json(path)
		return {} if ! File.exist? path
		JSON.parse File.read(path), :symbolize_names => true
	end

	def yearly_tag_data
		@yearly_tag_data ||= load_json '../yearly-tags.json'
	end

	def site_list
		['so', 'sf', 'su']
	end
end

get '/?:cur_site?/' do |cur_site|
	cur_site = 'so' if cur_site.nil?

	# generate the list of tags that we can click on
	popular_tags = DB.get_tags(cur_site)
	popular_tags.insert(0, {'tag_name'=> "ao-tag-#{settings.all_tag}", 'site'=>cur_site})

	# its the front page. Get the three main counters.
	q_count = DB.get_rate_from_rate("#{cur_site}-question");
	a_count = DB.get_rate_from_rate("#{cur_site}-answer");
	c_count = DB.get_rate_from_count("#{cur_site}-comment-count");
	count_data = [q_count, a_count, c_count];

	erb :home, :layout => :_layout, :locals => {
		:count_data => count_data,
		:site_list => site_list,
		:popular_tags => popular_tags,
		:so_tag => settings.all_tag,
		:so_tag_display => settings.all_tag,
		:cur_site => cur_site
	}
end

get '/:cur_site/:so_tag/' do |cur_site, so_tag|
	return 'not found' if so_tag == 'apache'

	cur_site = 'so' if cur_site.nil?

	so_tag = settings.all_tag if so_tag.nil?
	so_tag_display = so_tag

	# generate the list of tags that we can click on
	popular_tags = DB.get_tags(cur_site)
	popular_tags.insert(0, {'tag_name'=> "ao-tag-#{settings.all_tag}", 'site'=>cur_site})

	# is this one of the main 3 tags? they get treated differently...
	if ['question', 'answer', 'comment'].include?(so_tag)
		question_count_tag = "#{cur_site}-#{so_tag}-count"
		tag_type = so_tag + 's'
		so_tag_display = so_tag + 's'
	else	
		question_count_tag = "#{cur_site}-tag-#{so_tag}"
		tag_type = 'questions'
	end

	q_count = DB.get_rate_from_count(question_count_tag);
	count_data = [q_count];

	erb :tag, :layout => :_layout, :locals => {
		:count_data => count_data,
		:site_list => site_list,
		:popular_tags => popular_tags,
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
