require 'date'

class Numeric

	# will convert numbers like 3456789 to 3.45m - much easier for people
	# to easily understand
	def to_human(len = 3)

		unit = ''
		n = self
		n = self.to_f unless n.is_a? Numeric
		n = self.to_f if defined?(BigDecimal) && n.is_a?(BigDecimal)

		if n > 1100
			n /= 1000.0
			unit = 'k'
		end

		if n > 1100
			n /= 1000.0
			unit = 'm'
		end

		if n > 1100
			n /= 1000.0
			unit = 'T'
		end

		# now we have the unit and the number we want to format it in a 
		# nice way so there is a consistant number of characters
		s = n.to_s
		if s.length > len
			s = s[0..len]
			s.chop! if s[-1] == '.'
		end

		"#{s}#{unit}"
	end

	def to_n0
		self.round.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
	end
end


class Array

	def every(n)
		return select {|x| index(x) % n == 0}
	end

	def sample(n)
		return self.every((self.size / n).floor)
	end
end

class Fixnum
	def ordinalize
		if (11..13).include?(self % 100)
			"#{self}th"
		else
			case self % 10
				when 1; "#{self}st"
				when 2; "#{self}nd"
				when 3; "#{self}rd"
				else    "#{self}th"
			end
		end
	end
end
