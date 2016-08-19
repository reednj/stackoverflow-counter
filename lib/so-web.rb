# Nathan Reed, 29/04/2010

require 'json'
require 'rest-client'

class StackOverflow
    
    def initialize(site_name)
		@site_name = site_name
		@api_base_url = 'http://api.stackexchange.com/2.2';
	end
    
    def question_rate
        self.info['questions_per_minute']
    end
    
    def answer_rate
		self.info['answers_per_minute']
    end
    
    def question_count
        self.info['total_questions']
    end

	def answer_count
        self.info['total_answers']
	end

	def comments_count
    	self.info['total_comments']
	end
		
	def info
		@stats_doc ||= JSON.parse(RestClient.get("#{@api_base_url}/info", :params => {:site => @site_name }))
		@stats_doc['items'].first
	end
	
	def tags
		@tags_doc ||= JSON.parse(RestClient.get("#{@api_base_url}/tags", :params => {:site => @site_name, :pagesize => 100 }))
		@tags_doc['items']
	end

end



