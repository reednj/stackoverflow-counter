#!/usr/bin/env ruby

chdir "data-collector" unless File.exist? 'so-yearly.rb'
system 'rm ../data/yearly-tags.json'

(2009..Time.now.year).each do |year|
    system "./so-yearly.rb #{year}"
end
