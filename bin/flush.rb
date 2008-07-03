#!/usr/bin/ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'queue'

if ARGV.empty?
  puts "call with one or more slugs"
  exit
end

@thread_q = Queue.new :thread

# build list of months to flush
ARGV.each do |slug|
  `find listlibrary_archive/list/#{slug}/message -type d -wholename '*/????/??'`.split("\n").each do |key|
    year, month = key.split('/')[-2..-1]
    @thread_q.add :slug => slug, :year => year, :month => month
  end
  FileUtils.rm_rf "listlibrary_archive/list/#{slug}/message_list/"
  FileUtils.rm_rf "listlibrary_archive/list/#{slug}/thread/"
  FileUtils.rm_rf "listlibrary_archive/list/#{slug}/thread_list/"
end
