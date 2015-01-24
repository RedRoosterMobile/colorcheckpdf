#!/usr/bin/env ruby
require 'shellwords'

if ARGV.length==0
  puts '[USAGE]: colorcheck.rb PATH_TO_PDF'
  exit
end

file = ARGV.first

unless File.exist? file
  puts "[ERROR]: file does not exist\n #{file}"
  exit
end


class Array
  def to_ranges
    compact.sort.uniq.inject([]) do |r,x|
      r.empty? || r.last.last.succ != x ? r << (x..x) : r[0..-2] << (r.last.first..x)
    end
  end
end

gs_output = `gs  -o - -sDEVICE=inkcov #{Shellwords.shellescape file}`

current_page = 0
colored_pages = []

gs_output.each_line do |line|

  page_line = line.match(/Page [0-9]+/)
  if page_line.to_s.include? 'Page '
    current_page = page_line.to_s.split(' ').last
  else
    unless current_page==0
      # is color-info line?
      if line.start_with? ' '
        parts = line.split(' ')
        # first three equal is grey! ignore key (black)
        unless (parts.first == parts[1]) and (parts.first == parts[2])
          # first C,M,Y are different, colored page
          colored_pages.push current_page.to_i
        end
      end
    end
  end
end

puts '[RESULT]:'
if colored_pages.length > 0
  output = []
  colored_pages.to_ranges.each do |range|
    range_array = range.to_a
    if range_array.length > 1
      output.push "#{range_array.first}-#{range_array.last}"
    else
      output.push range_array.first.to_s
    end
  end
  puts output.join(',')
else
  # save for grayscale conversion
  puts 'ALL GREY'
end