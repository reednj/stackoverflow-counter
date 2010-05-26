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

    so = StackOverflow.new();
    dbh =  SoSql.real_connect();

	# insert the total question count and rate
	dbh.insert_tagvalue("#{$SITE_TAG_PREFIX}-question-count", so.question_count);
	dbh.insert_tagvalue("#{$SITE_TAG_PREFIX}-question-rate", so.question_rate);
	puts 'question count+rate added'

	# insert the current question/answer id. Not sure if this counts for comments as well?
	dbh.insert_tagvalue("#{$SITE_TAG_PREFIX}-answer-count", so.answer_count);
	dbh.insert_tagvalue("#{$SITE_TAG_PREFIX}-answer-rate", so.answer_rate);
	puts 'answer count+rate added'

	# insert the comment count
	dbh.insert_tagvalue("#{$SITE_TAG_PREFIX}-comment-count", so.comments_count);
	puts "comment count added";

	# insert the count for each of the tags	
	sleep(REQUEST_DELAY);
	so.tag_counts.each do |curtag|
		dbh.insert_tagvalue("#{$SITE_TAG_PREFIX}-tag-#{curtag['name']}", curtag['count']);
	end
	puts 'question counts added (grouped by tag)'
    
    dbh.close;
    
end

main();


