require 'sinatra'
require 'sinatra/json'
require 'sinatra/content_for'
require "sinatra/reloader" if development?

require 'json'
require 'yaml'
require 'erubis'

require './lib/models'
require './lib/extensions'
require './lib/sinatra-object_cache'

#set :raise_errors, false
#set :show_exceptions, true

set :version, '3.0'
set :erb, :escape_html => true

set :all_tag, 'all'
set :max_tags, 50
set :max_tags_default, 4

configure :development do
	also_reload './lib/extensions.rb'
	also_reload './lib/models.rb'
	also_reload './lib/sinatra-object_cache.rb'
end

helpers do
	def load_json(path)
		return {} if ! File.exist? path
		JSON.parse File.read(path), :symbolize_names => true
	end

	def yearly_tag_data
		begin
			path = File.exist?('../yearly-tags.json') ? '../yearly-tags.json' : 'yearly-tags.json'
			@yearly_tag_data ||= load_json(path)
		rescue => e
			{}
		end
	end

	def site_list
		['so', 'sf', 'su']
	end
end

get '/testcache' do
	cache_object :for => 10.0 do
		sleep 1.5
		Time.now.to_s
	end
end

get '/?:cur_site?/' do |cur_site|
	cur_site ||= 'so'

	count_data = cache_object(:for => 60.0) do
		{
			:comments => Tag.with_name("#{cur_site}-comment-count").latest_value,
			:answers => Tag.with_name("#{cur_site}-answer-count").latest_value,
			:questions => Tag.with_name("#{cur_site}-question-count").latest_value
		}
	end

	erb :home, :layout => :_layout, :locals => {
		:count_data => count_data,
		:popular_tags => Tag.top_tags(cur_site).first(settings.max_tags),
		:so_tag => settings.all_tag,
		:cur_site => cur_site,
		:show_yearly_tag_data => (cur_site == 'so'),
		:data_age => count_data[:questions].age
	}
end

get '/:cur_site/:so_tag/?' do |cur_site, so_tag|
	cur_site ||= 'so'
	so_tag ||= settings.all_tag
	
	so_tag_display = so_tag
	tag_name = "#{cur_site}-tag-#{so_tag}"
	count_data = cache_object(:for => 60.0 * 15) do 
		Tag.with_name(tag_name).latest_value
	end

	halt 404, 'tag not found' if count_data.nil?

	erb :tag, :layout => :_layout, :locals => {
		:count_data => count_data,
		:popular_tags => Tag.top_tags(cur_site).first(settings.max_tags),
		:so_tag => so_tag,
		:so_tag_display => so_tag_display,
		:tag_name => tag_name,
		:cur_site => cur_site,
		:data_age => count_data.age
	}
end

