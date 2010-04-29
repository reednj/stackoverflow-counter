# Nathan Reed, 29/04/2010

require 'mysql'


class EasySql < Mysql

    def self.real_connect()
        super(@db_server, @db_user, @db_pass, @db_name);
    end

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

class SoSql < EasySql
	
	def self.real_connect()
		
		@db_server = 'localhost';
		@db_name = 'stackoverflow_count';
		@db_user = 'linkuser';
		@db_pass = '';

		super;		
	end

	def get_rate(tag_name, look_back = 2)

		count_data = self.get_counts(tag_name, look_back);
	
		count = count_data[0]['tag_value'].to_f;
		age = count_data[0]['age'].to_f;
		rate = (count - count_data[look_back - 1]['tag_value'].to_f) / (count_data[look_back - 1]['age'].to_f - age);

		return {'tag_name' => tag_name, 'count' => count, 'age' => age, 'rate' => rate};

	end

	def get_counts(tag_name, limit = 50)
		tag_name = self.escape_string(tag_name);
		limit  = Integer(limit);

		return self.easy_query("select 
			tv.value_id,
			t.tag_id,
			t.tag_name, 
			tv.tag_value,
			tv.created_date,
			unix_timestamp() - unix_timestamp(tv.created_date) as age
		from TagValue tv
			inner join Tag t on t.tag_id = tv.tag_id
		where tag_name = '#{tag_name}'
		order by value_id desc 
		limit #{limit}");

	end

	def get_counts_by_id(tag_id, limit = 50)
		tag_id = self.escape_string(tag_id);
		limit  = Integer(limit);

		return self.easy_query("select value_id, tag_id, .tag_value, created_date, unix_timestamp() - unix_timestamp(created_date) as age from TagValue where tag_id = '#{tag_id}' order by value_id desc limit #{limit}");
	end

	def get_tags()
		return self.easy_query("select tag_id, tag_name from Tags limit 200");
	end

end