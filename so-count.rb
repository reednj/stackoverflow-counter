#!/usr/bin/ruby

require 'rubygems';
require 'nokogiri';
require 'open-uri';
require 'mysql';

def main()
    so = StackOverflow.new();
    dbh =  SOsql.new();
    dbh.easy_connect;

	# insert the total question count
	question_tag_id = dbh.get_tag('so-question-count');
	dbh.insert_tagvalue(question_tag_id, so.question_count);

	# insert the count for each of the tags	
	so.tag_counts.each do |curtag|
		tag_id = dbh.get_tag("so-tag-#{curtag['name']}");
		dbh.insert_tagvalue(tag_id, curtag['count']);
	end
    
    dbh.close;
    
end

class StackOverflow
    
    def initialize()
		@question_url = 'http://stackoverflow.com/questions';
		@tag_url = 'http://stackoverflow.com/tags';
	end
    
    def question_count()
        doc = Nokogiri::HTML(open(@question_url));

        e = doc.css('.module .summarycount')[0];
        question_count = Integer(e.content.gsub(/[^0-9]/, ''));
        return question_count;
    end

	def tag_counts()
		doc = Nokogiri::HTML(open(@tag_url));

		tag_data = doc.css('.post-tag').map do |curtag|
			{'name' => curtag.content, 'count' => curtag.next.content.gsub(/[^0-9]/, '').to_i};
		end

		return tag_data
	end
    

end

class SOsql < Mysql

    def easy_connect()
        self.real_connect("localhost", "linkuser", "", "stackoverflow_count");
    end

    def insert_tagvalue(tag_id, tag_value)
        tag_id = Integer(tag_id);
        tag_value = Float(tag_value);

        self.easy_query("insert into TagValue (tag_id, tag_value) values (#{tag_id}, #{tag_value})");
    end

	def insert_tag(tag_name)
		tag_name = self.escape_string(tag_name)
		self.easy_query("insert ignore into Tag (tag_name) values ('#{tag_name}')");

		return self.insert_id
	end

	# returns the tag_id.
	# if the tag doesn't exist, it will be created.
	def get_tag(tag_name)
		tag_name = self.escape_string(tag_name)
		tag_data = self.easy_query("select tag_id from Tag where tag_name = '#{tag_name}'");

		if tag_data.empty?
			tag_id = self.insert_tag(tag_name)
		else
			tag_id = tag_data[0]['tag_id'];
		end

		return tag_id;
	end

end

class Mysql

    def easy_query(query_string)
        result = [];
        res = self.query(query_string);

        if res.nil?
            return nil;
        end

        i=0; res.each_hash do |row| 
            result[i] = row;
            i += 1;
        end

        return result;
    end

end

main();


