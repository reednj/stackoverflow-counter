# Released under MIT-style License (see license.txt)
# Nathan Reed, 2010-05-29

class Array

	def simple_encode(max_val = nil, min_val=0, max_buffer = 1.1)
		return '' if self.empty?
		max_val = self.flatten.max if max_val.nil?
		min_val = self.flatten.min if min_val.nil?
		
		result = self.map do |item|
			 item.simple_encode(max_val, min_val);
		end
		
		if self.all_arrays?
			return result.join(',');
		else
			return result.join;
		end
		
	end
	
	def all_arrays?
		self.each do |item|
			return false if !item.kind_of?(Array)
		end
		
		return true
	end

end

class Fixnum
	def simple_encode(max, min=0)
		max = max.to_f
		min = min.to_f
	
		key = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
		key_index = (self.to_f - min) / (max - min) * (key.length-1);
		return key[key_index.round(), 1]
		
	end
end

class GoogleChart
	def initialize(params = nil)
		@base_url = 'http://chart.apis.google.com/chart'
		
		if !params.nil?
			@type = params[:type];
			@height = params[:height];
			@width = params[:width];
			@labels = params[:labels];
			@titles = params[:titles];
			@spacing = params[:spacing];
			@color = params[:color];
			
			@zero_start = true
			@zero_start = params[:zero_start] if !params[:zero_start].nil?;
			
			
		end
	end
	
	def generate(data)
		return nil if data.nil? or data.empty?
	
		url_params = ['chxp=0,0', 'chxt=x,y'];
		
		url_params << self.type_s('Bar') if @type.nil?;
		url_params << self.data_s(data, @zero_start);
		url_params << self.axis_s(data, @zero_start);
		
		if @height.nil? or @width.nil?
			url_params << self.size_s(200, 75);
		else 
			url_params << self.size_s(@width, @height);
		end

		url_params << self.type_s(@type) if !@type.nil?;
		url_params << self.labels_s(@labels) if !@labels.nil?;
		url_params << self.title_s(@titles) if !@titles.nil?;
		url_params << self.spacing_s(@spacing) if !@spacing.nil?;
		url_params << self.colors_s(@color) if !@color.nil?;

		return "#{@base_url}?#{url_params.join('&')}"
	end
	
	# for bar graphs only
	def spacing_s(space_pct)
		return "chbh=r,#{space_pct.to_f/100},1.0"
	end
	
	def colors_s(color)
		return "chco=" + color
	end
	
	def title_s(title)
		if title.kind_of?(Array)
			return 'chtt=' + title.join('|')
		else
			return 'chtt=' + title
		end
	end
	
	def labels_s(label_list)
		return 'chl=' + label_list.join('|')
	end
	
	def size_s(width, height)
		return "chs=#{width}x#{height}"
	end
	
	def type_s(type_string)
		if type_string == 'Bar'
			return 'cht=bvs'
		elsif type_string =='Line'
			return 'cht=lc'
		end
	end
	
	def data_s(series_array, zero_start=true)
		if(zero_start)
			result = "chd=s:" + series_array.simple_encode
		else
			# we set the min to 'nil' this will mean it is calculated from actual
			# data, instead of assuming the min is zero, like default.
			result = "chd=s:" + series_array.simple_encode(nil, nil)
		end
		
		return result;
	end
	
	def axis_s(data_array, zero_start=true)
		min_val = 0.001
		min_val = data_array.flatten.min if zero_start == false
		max_val = data_array.flatten.max * 1.1
		
		return "chxr=1,#{min_val},#{max_val}"
	end
	


	
end