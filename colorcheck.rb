#!/usr/bin/env ruby
require 'shellwords'
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
require 'ghost_script_parser'

if ARGV.length==0
  puts '[USAGE]: colorcheck.rb PATH_TO_PDF'
  exit
end

file = ARGV.first

unless File.exist? file
  puts "[ERROR]: file does not exist\n #{file}"
  exit
end


gs_output = `gs  -o - -sDEVICE=inkcov #{Shellwords.shellescape file}`

gsp = GhostScriptParser.new gs_output, :inkcov

puts '[RESULT]:'
if gsp.colored_pages?
  puts gsp.colored_pages_range_string
else
  # safe for grayscale conversion
  puts 'ALL GREY'
end