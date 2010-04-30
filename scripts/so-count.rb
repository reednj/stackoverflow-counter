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

	# insert the total question count
	question_tag_id = dbh.get_tag('so-question-count');
	dbh.insert_tagvalue(question_tag_id, so.question_count);
	puts 'question count added'
	sleep(REQUEST_DELAY);

	# insert the current question/answer id. Not sure if this counts for comments as well?
	answer_tag_id = dbh.get_tag('so-answer-count');
	dbh.insert_tagvalue(answer_tag_id, so.answer_count);
	puts 'answer count added'
	sleep(REQUEST_DELAY);

	# insert the count for each of the tags	
	so.tag_counts.each do |curtag|
		tag_id = dbh.get_tag("so-tag-#{curtag['name']}");
		dbh.insert_tagvalue(tag_id, curtag['count']);
	end
	puts 'question counts added (grouped by tag)'
	sleep(REQUEST_DELAY);

	# insert a bunch of comment ids
	comment_count = 0;
	comment_tag = dbh.get_tag('so-comment-count');

	so.get_comments.each do |c|
		comment_time = Time.parse(c['time_utc']).localtime.strftime("%Y-%m-%d %H:%M:%S");
		dbh.insert_tagvalue(comment_tag, c['id'], comment_time);

		comment_count += 1;
	end
	puts "comment counts added (#{comment_count} records)";
    
    dbh.close;
    
end

main();


