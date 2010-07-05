#!/usr/bin/ruby

$LOAD_PATH << './lib' << '../shared'

require 'rubygems';
require 'nokogiri';
require 'open-uri';
require 'mysql';

require 'so-db';
require 'so-web';

REQUEST_DELAY = 3;

def main()
	site_prefix = $SITE_TAG_PREFIX;
	site_prefix = ARGV[-2][0..1] if ARGV.size == 2
	
	api_address = 'http://api.stackoverflow.com/0.9/'
	api_address = ARGV[-1] if ARGV.size == 2

    so = StackOverflow.new(api_address);
    dbh =  SoSql.real_connect();

	puts 'analyticsoverflow data retriever - Nathan Reed (c) 2010'
	puts "getting data for: '#{api_address}'"
	
	# insert the total question count and rate
	dbh.insert_tagvalue("#{site_prefix}-question-count", so.question_count);
	dbh.insert_tagvalue("#{site_prefix}-question-rate", so.question_rate);
	puts '  question count+rate added'

	# insert the current question/answer id. Not sure if this counts for comments as well?
	dbh.insert_tagvalue("#{site_prefix}-answer-count", so.answer_count);
	dbh.insert_tagvalue("#{site_prefix}-answer-rate", so.answer_rate);
	puts '  answer count+rate added'

	# insert the comment count
	dbh.insert_tagvalue("#{site_prefix}-comment-count", so.comments_count);
	puts "  comment count added";

	# insert the count for each of the tags	
	sleep(REQUEST_DELAY);
	so.tag_counts.each do |curtag|
		dbh.insert_tagvalue("#{site_prefix}-tag-#{curtag['name']}", curtag['count']);
	end
	puts '  question counts added (grouped by tag)'
    
    dbh.close;
    
end

main();


