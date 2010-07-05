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
    
    def initialize(api_url)
		
		@api_base_url = api_url;
		@stats_cmd = 'stats';
		@tags_cmd = 'tags';
		
		# save the returned docs.
		@stats_doc = nil;
		@tags_doc = nil;
	end
    
    def question_rate()
    	stats_data = self.get_stats();
        return stats_data['statistics'][0]['questions_per_minute'];
    end
    
    def answer_rate()
    	stats_data = self.get_stats();
        return stats_data['statistics'][0]['answers_per_minute'];
    end
    
    def question_count()
    	stats_data = self.get_stats();
        return stats_data['statistics'][0]['total_questions'];
    end

	def answer_count()
    	stats_data = self.get_stats();
        return stats_data['statistics'][0]['total_answers'];
	end

	def comments_count()
    	stats_data = self.get_stats();
        return stats_data['statistics'][0]['total_comments'];
	end
	
	def tag_counts()
    	tags_data = self.get_tags();
		return tags_data['tags'];
	end
	
	def get_stats()
		if @stats_doc == nil
			@stats_doc = JSON.parse(open(@api_base_url + @stats_cmd).inflate)
		end
		
		return @stats_doc;
	end
	
	def get_tags()
		if @tags_doc == nil
			@tags_doc = JSON.parse(open(@api_base_url + @tags_cmd).inflate)
		end
		
		return @tags_doc;
	end

end



