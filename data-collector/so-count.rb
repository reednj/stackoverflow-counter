#!/usr/bin/env ruby

require 'rubygems'
require 'mysql'

require '../lib/so-db'
require '../lib/so-web'

REQUEST_DELAY = 3;

def main()
	site_prefix = 'so'
	site_prefix = ARGV[-2][0..1] if ARGV.size == 2

	site_name = 'stackoverflow'
	site_name = ARGV[-1] if ARGV.size == 2

    so = StackOverflow.new(site_name);
    dbh =  SoSql.real_connect();

	puts "getting data for '#{site_name}'"
	
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
	so.tags.each do |curtag|
		dbh.insert_tagvalue("#{site_prefix}-tag-#{curtag['name']}", curtag['count']);
	end
	puts '  question counts added (grouped by tag)'
   
    dbh.close;
    
end

main();


