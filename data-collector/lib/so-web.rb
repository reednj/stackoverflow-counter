# Nathan Reed, 29/04/2010

require 'json'
require 'zlib' 
require 'open-uri'

# I would have thought that open-uri would inflate gzipped responses automatically, but
# apparently not.
class StringIO
	def inflate()
		return Zlib::GzipReader.new(self).read
	end
end

class StackOverflow
    
    def initialize()
		
		@api_base_url = 'http://api.stackoverflow.com/0.8/';
		@stats_cmd = 'stats';
		@tags_cmd = 'tags'
		
		@stats_doc = nil;
		@tags_doc = nil;
	end
    
    def question_rate()
        if @stats_doc == nil
			@stats_doc = JSON.parse(open(@api_base_url + @stats_cmd).inflate)
		end

        return @stats_doc['statistics'][0]['questions_per_minute'];
    end
    
    def answer_rate()
    	if @stats_doc == nil
			@stats_doc = JSON.parse(open(@api_base_url + @stats_cmd).inflate)
		end

        return @stats_doc['statistics'][0]['answers_per_minute'];
    end
    
    def question_count()
		if @stats_doc == nil
			@stats_doc = JSON.parse(open(@api_base_url + @stats_cmd).inflate)
		end

        return @stats_doc['statistics'][0]['total_questions'];
    end

	def answer_count()
		if @stats_doc == nil
			@stats_doc = JSON.parse(open(@api_base_url + @stats_cmd).inflate)
		end

        return @stats_doc['statistics'][0]['total_answers'];
	end

	def get_comments()
		if @stats_doc == nil
			@stats_doc = JSON.parse(open(@api_base_url + @stats_cmd).inflate)
		end

        return @stats_doc['statistics'][0]['total_comments'];
	end
	
	def tag_counts()
		if @tags_doc == nil
			@tags_doc = JSON.parse(open(@api_base_url + @tags_cmd).inflate)
		end

		return @tags_doc['tags']
	end

end



