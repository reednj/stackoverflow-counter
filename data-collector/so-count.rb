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
	question_tag_id = dbh.get_tag('so-question-count');
	question_rate_tag_id = dbh.get_tag('so-question-rate');
	dbh.insert_tagvalue(question_tag_id, so.question_count);
	dbh.insert_tagvalue(question_rate_tag_id, so.question_rate);
	puts 'question count+rate added'

	# insert the current question/answer id. Not sure if this counts for comments as well?
	answer_tag_id = dbh.get_tag('so-answer-count');
	answer_rate_tag_id = dbh.get_tag('so-answer-rate');
	dbh.insert_tagvalue(answer_tag_id, so.answer_count);
	dbh.insert_tagvalue(answer_rate_tag_id, so.answer_rate);
	puts 'answer count+rate added'

	# insert the comment count
	comment_tag = dbh.get_tag('so-comment-count');
	dbh.insert_tagvalue(comment_tag, so.get_comments);
	puts "comment count added";

	# insert the count for each of the tags	
	sleep(REQUEST_DELAY);
	so.tag_counts.each do |curtag|
		tag_id = dbh.get_tag("so-tag-#{curtag['name']}");
		dbh.insert_tagvalue(tag_id, curtag['count']);
	end
	puts 'question counts added (grouped by tag)'
    
    dbh.close;
    
end

main();


