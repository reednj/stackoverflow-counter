# Nathan Reed, 29/04/2010


class StackOverflow
    
    def initialize()
		@MIN_COMMENTS = 3;
		@MAX_QUESTIONS = 3;

		@question_url_base = 'http://stackoverflow.com/questions/';
		@question_url = 'http://stackoverflow.com/questions?sort=newest';
		@tag_url = 'http://stackoverflow.com/tags';
		@question_doc = nil
	end
    
    def question_count()
		if @question_doc == nil
			self.get_recent_questions
		end

        e = @question_doc.css('.module .summarycount')[0];
        question_count = Integer(e.content.gsub(/[^0-9]/, ''));
        return question_count;
    end

	def answer_count()
		if @question_doc == nil
			self.get_recent_questions
		end

        e = @question_doc.css('.question-summary')[0];
        return e['id'].split('-')[2].to_i;
	end

	def tag_counts()
		doc = Nokogiri::HTML(open(@tag_url));

		tag_data = doc.css('.post-tag').map do |curtag|
			{'name' => curtag.content, 'count' => curtag.next.content.gsub(/[^0-9]/, '').to_i};
		end

		return tag_data
	end

	def get_recent_questions()
		@question_doc = Nokogiri::HTML(open(@question_url));
	end

	# opens a bunch of questions until it has enough comments
	# or has gone through enough pages to give up.
	def get_comments()
		question_data = self.get_question_list
		comment_data = [];

		question_data[0, @MAX_QUESTIONS].each do |question|
			comment_data += self.get_question_comments(question['id']);
			if comment_data.size >= @MIN_COMMENTS
				break
			end

			sleep(5);
		end

		return comment_data;
	end

	def get_question_comments(question_id)
		question_url = @question_url_base + question_id.to_s;

		doc = Nokogiri::HTML(open(question_url));
		comments = doc.css('.comment')

		return comments.map do |c|
			{'id' => c['id'].gsub(/[^0-9]/, '').to_i, 'time_utc' => c.css('.comment-date span').first['title']}
		end

	end

	# return a list of question ids, sorted by the number of views they have
	def get_question_list()
		doc = Nokogiri::HTML(open('http://stackoverflow.com/questions?page=3&sort=newest'));
		question_list = doc.css('.question-summary');

		# get a list of all question ids, and the number of views
		question_data = question_list.map do |q|
			{'id' => q['id'].gsub(/[^0-9]/, '').to_i, 'views' => q.css('.views')[0].content.gsub(/[^0-9]/, '').to_i};
		end

		return question_data.sort_by {|a| -a['views']};

	end

end

