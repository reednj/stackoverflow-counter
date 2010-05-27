
class Array

	def simple_encode(max_buffer = 1.1)
		max_val = self.max * max_buffer if !self.empty?
		result = []

		result = self.map do |value|
			 value.simple_encode(max_val);
		end
		
		return result.join;
	end

end

class Fixnum
	def simple_encode(max)
		key = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
		key_index = self.to_f / max.to_f * (key.length-1);
		return key[key_index.round(), 1]
	end
end

class GoogleChart
	def initialize(params = nil)
		@base_url = 'http://chart.apis.google.com/chart'
		
		if !params.nil?
			@height = params[:height];
			@width = params[:width];
			@labels = params[:labels];
			@titles = params[:titles];
			@spacing = params[:spacing];
			@color = params[:color];
		end
	end
	
	def generate(data)
		return nil if data.nil? or data.empty?
	
		url_params = ['chxp=0,0', 'chxt=x,y'];
		
		url_params << self.type_s('Bar');
		url_params << self.data_s(data);
		url_params << self.axis_s(data);
		
		if @height.nil? or @width.nil?
			url_params << self.size_s(200, 75);
		else 
			url_params << self.size_s(@width, @height);
		end
		
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
		end
	end
	
	def data_s(data_array)
		return "chd=s:" + data_array.simple_encode
	end
	
	def axis_s(data_array)
		min_val = 0.001
		max_val = data_array.max * 1.1
		
		return "chxr=1,#{min_val},#{max_val}"
	end
	


	
end