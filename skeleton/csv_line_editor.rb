#!/usr/bin/env ruby
# encoding: UTF-8

require "csv"
#require "pry"

#FileIn = ARGV
#FileOut = $stdout
CsvOptionsRead = {
  headers: true,
  converters: :integer,
}
CsvOptionsWrite = {
  #write_headers: true,
}
ProgressInterval = 100

$csv = CSV.new STDOUT, CsvOptionsWrite
$headers = []

def process_headers(headers)
  return unless $headers.size == 0

  # write code here
  $headers = headers

  $csv << $headers
end
def process_row(row, idx)
  # write code here

  row
end

ARGV.each do |fn|
  $stderr.puts "reading #{fn} :"
  CSV.foreach(fn, CsvOptionsRead).with_index do |row,idx|
    putc '.' if idx % ProgressInterval == 0
    process_headers row.headers if idx == 0
    row = process_row row, idx

    $csv << row unless row.nil?
  end
  $stderr.puts "[done]"
end
