# Nathan Reed, 29/04/2010

load 'so-config.rb'
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
		
		@db_server = $DB_HOST;
		@db_name = $DB_NAME;
		@db_user = $DB_USER;
		@db_pass = $DB_PASS;

		super;		
	end

	def get_rate_from_count(tag_name)

		count_data = self.get_prev(tag_name);
		
		if count_data.nil? or count_data.size == 0
			return {'tag_name' => tag_name, 'count' => 0, 'age' => 0, 'rate' => 0}
		end
	
		count = count_data[0]['tag_value'].to_f;
		age = count_data[0]['age'].to_f;
		rate = (count - count_data[1]['tag_value'].to_f) / (count_data[1]['age'].to_f - age);

		return {'tag_name' => tag_name, 'count' => count, 'age' => age, 'rate' => rate};

	end
	
	def get_rate_from_rate(base_tag_name)
		count_data = self.get_tagvalue(base_tag_name+'-count');
		rate_data = self.get_tagvalue(base_tag_name+'-rate');
		
		count = count_data[0]['tag_value'].to_f;
		age = count_data[0]['age'].to_f;
		rate = rate_data[0]['tag_value'].to_f / 60;

		return {'tag_name' => base_tag_name+'-count', 'count' => count, 'age' => age, 'rate' => rate};
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
		order by created_date desc 
		limit #{limit}");

	end
	
	def get_prev(tag_id)
		# if we've been given a tagname, then convert it to an id
		if tag_id.kind_of?(String)
			tag_id = self.get_tag(tag_id);
		end
	
		current_data = self.get_counts_by_id(tag_id, 1);
		prev_data = self.easy_query("select 
			value_id, 
			tag_id, tag_value, 
			created_date, 
			unix_timestamp() - unix_timestamp(created_date) as age 
		from TagValue 
		where 
			tag_id = '#{tag_id}' and
			value_id < '#{current_data[0]["value_id"]}' and
			tag_value != '#{current_data[0]["tag_value"]}'
		order by value_id 
		desc limit 1");
		
		return [current_data[0], prev_data[0]];
	end
	
	def get_tagvalue(tag_name, limit = 1)
    	return get_counts_by_id(tag_name, limit)
    end
    
	def get_counts_by_id(tag_id, limit = 50)
	    if tag_id.kind_of?(String)
			tag_id = self.get_tag(tag_id);
		end
		
		tag_id = Integer(tag_id);
		limit  = Integer(limit);

		return self.easy_query("select value_id, tag_id, tag_value, created_date, unix_timestamp() - unix_timestamp(created_date) as age from TagValue where tag_id = '#{tag_id}' order by value_id desc limit #{limit}");
	end

	def get_tags()
		return self.easy_query("select tag_id, tag_name from Tags limit 200");
	end

    def insert_tagvalue(tag_id, tag_value)
    	if tag_id.kind_of?(String)
			tag_id = self.get_tag(tag_id);
		end
    
        tag_id = Integer(tag_id);
        tag_value = Float(tag_value);

        self.easy_query("insert ignore into TagValue (tag_id, tag_value) values (#{tag_id}, #{tag_value})");
		
    end

	def insert_tag(tag_name)
		tag_name = self.escape_string(tag_name)
		self.easy_query("insert ignore into Tag (tag_name) values ('#{tag_name}')");

		return self.insert_id
	end

	# returns the tag_id.
	# if the tag doesn't exist, it will be created.
	def get_tag(tag_name, create_tag = true)
		tag_id = nil
		tag_name = self.escape_string(tag_name)
		tag_data = self.easy_query("select tag_id from Tag where tag_name = '#{tag_name}'");

		if tag_data.empty? and create_tag == true
			tag_id = self.insert_tag(tag_name)
		else
			tag_id = tag_data[0]['tag_id'];
		end

		return tag_id;
	end

end
