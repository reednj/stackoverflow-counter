# Nathan Reed, 29/04/2010

require_relative './so-config.rb'
require 'mysql'
require 'date'
require_relative './extensions'

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

	def daily_graph_values(tag_id, label_count = 3)
		if tag_id.kind_of?(String)
			tag_id = self.get_tag(tag_id, false);
			return {'data' => nil, 'labels' => nil} if tag_id.nil?
		end

		daily_data = self.daily_values(tag_id);

		data_values = daily_data.map do |item|
			item['max_value'].to_i - item['min_value'].to_i;
		end

		label_values = daily_data.map do |item|
			d = Date.parse(item['value_date']);
			d.day.ordinalize
		end

		return {'data' => data_values.reverse, 'labels' => label_values.reverse.sample(label_count)}
	end

	def daily_values(tag_id, max_records = 14)

		tag_id = Integer(tag_id)
		max_records = Integer(max_records)

		data = self.easy_query("
		select
			tag_id,
			date(created_date) as value_date,
			min(tag_value) as min_value,
			max(tag_value) as max_value
		from (
			select
				tag_id,
				tag_value,
				created_date
			from TagValue
			where
				tag_id = #{tag_id} and date(created_date) != date(now()) and
				created_date > (now() - INTERVAL 2 WEEK)
		) a
		group by date(created_date)
		order by date(created_date) desc
		limit #{max_records}");

		return data;
	end

	# get the rate data by looking at two values of a count tag
	def get_rate_from_count(tag_name)

		count_data = self.get_tagvalue_prev(tag_name);

		if !count_data.nil?
			count = count_data[0]['tag_value'].to_f;
			age = count_data[0]['age'].to_f;
			rate = (count - count_data[1]['tag_value'].to_f) / (count_data[1]['age'].to_f - age);
		else
			count = 0;
			age = 0;
			rate = 0;
		end

		return {'tag_name' => tag_name, 'count' => count, 'age' => age, 'rate' => rate};

	end

	# get the rate data from an actual rate tag. Atm these only exist for question, answer and badge rates
	def get_rate_from_rate(base_tag_name)
		count_data = self.get_tagvalue(base_tag_name+'-count');
		rate_data = self.get_tagvalue(base_tag_name+'-rate');

		if !count_data.nil? and !rate_data.nil?
			count = count_data[0]['tag_value'].to_f;
			age = count_data[0]['age'].to_f;
			rate = rate_data[0]['tag_value'].to_f / 60; # rate tags give events/min. we need events/sec
		else
			count = 0;
			age = 0;
			rate = 0;
		end

		return {'tag_name' => base_tag_name+'-count', 'count' => count, 'age' => age, 'rate' => rate};
	end

	# gets the current value of the tag, and well as the most recent entry
	# before it with a different value. This allows us to calculate the rate
	def get_tagvalue_prev(tag_id)
		# if we've been given a tagname, then convert it to an id
		if tag_id.kind_of?(String)
			tag_id = self.get_tag(tag_id, false);
			return nil if tag_id.nil?
		end

		current_data = self.get_tagvalue(tag_id, 1);

		if current_data.nil? or current_data[0].nil?
			return nil;
		end

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

		if !current_data.nil? and !prev_data.nil?
			return [current_data[0], prev_data[0]];
		else
			return nil;
		end
	end

	def get_tagvalue(tag_id, limit = 1)
	    if tag_id.kind_of?(String)
			tag_id = self.get_tag(tag_id, false);
			return nil if tag_id.nil?
		end

		tag_id = Integer(tag_id);
		limit  = Integer(limit);

		return self.easy_query("select value_id, tag_id, tag_value, created_date, unix_timestamp() - unix_timestamp(created_date) as age from TagValue where tag_id = '#{tag_id}' order by value_id desc limit #{limit}");
	end

    def insert_tagvalue(tag_id, tag_value)

    	#tag_name = tag_id

    	if tag_id.kind_of?(String)
			tag_id = self.get_tag(tag_id);
		end

        tag_id = Integer(tag_id);
        tag_value = Float(tag_value);

		# update the tags. This is temporary.
		#data = self.extract_tag_details(tag_name)
		#self.update_tag(tag_id, data['desc'], data['site'])

        self.easy_query("insert ignore into TagValue (tag_id, tag_value) values (#{tag_id}, #{tag_value})");

    end

	# returns the tag_id.
	# if the tag doesn't exist, it will be created.
	def get_tag(tag_name, create_tag = true)
		return tag_name if !tag_name.kind_of?(String)

		tag_id = nil
		tag_name = self.escape_string(tag_name)
		tag_data = self.easy_query("select tag_id from Tag where tag_name = '#{tag_name}'");

		if tag_data.empty?
			if create_tag == true
				tag_id = self.insert_tag(tag_name)
			else
				return nil
			end
		else
			tag_id = tag_data[0]['tag_id'];
		end

		return Integer(tag_id);
	end

	def insert_tag(tag_name)
		tag_name = self.escape_string(tag_name)
		tag_attr = self.extract_tag_details(tag_name)

		self.easy_query("insert ignore into Tag (tag_name, site, description) values ('#{tag_name}', '#{tag_attr['site']}', '#{tag_attr['desc']}')");

		return self.insert_id
	end

	# takes the tag name, and returns the site and description.
	def extract_tag_details(tag_name)
		data = tag_name.split('-', 3)

		if data[1] == 'tag'
			desc = data[2]
		else
			desc = data[1]
		end

		return {'tag_name'=>tag_name, 'site'=>data[0], 'desc'=>desc}
	end

	def update_tag(tag_id, desc, site)
		desc = self.escape_string(desc)
		site = self.escape_string(site)

		return self.easy_query("update Tag set description='#{desc}', site='#{site}' where tag_id=#{tag_id}")
	end

	def get_tags(site, count=32)
		site = self.escape_string(site)
		return self.easy_query("select tag_id, tag_name, site, description, created_date from Tag where site='#{site}' and tag_name like '%-tag-%' limit #{count}")
	end

end
