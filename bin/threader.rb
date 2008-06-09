#!/usr/bin/ruby

require 'ostruct'

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'storage'
require 'list'
require 'log'
require 'queue'
require 'tempfile'
require 'threading'

class Threader
  attr_accessor :jobs, :stop_on_empty

  def initialize
    @thread_q = Queue.new :thread
  end

  def get_job
    @thread_q.next
  end

  def run
    log = Log.new "Threader"
    log.block "threader" do |log|
    while job = get_job
      log.block job.key do |log|
      slug, year, month = job[:slug], job[:year], job[:month]
      list = List.new slug

      cached_message_list = list.cached_message_list year, month
      fresh_message_list  = list.fresh_message_list year, month

      if cached_message_list == fresh_message_list
        log.status "nothing to do"
        next
      end

      # if any messages were removed, rebuild for saftey over the speed of find and remove
      removed = (cached_message_list - fresh_message_list)
      if !removed.empty?
        threadset = ThreadSet.new
        added = fresh_message_list
      else
        threadset = ThreadSet.month(slug, year, month)
        added = fresh_message_list - cached_message_list 
        log.status "#{fresh_message_list.size} messages, #{cached_message_list .size} in cache, adding #{added.size}"
      end

      # add messages
      added.each_with_index do |key, i|
        threadset << $storage.load_yaml('listlibrary_archive', key)
      end

      cache_work(slug, year, month, fresh_message_list, threadset) unless removed.empty? and added.empty?
      queue_renderer(slug, year, month, threadset) unless removed.empty? and added.empty?
      end # log
    end
    end
  end

  def cache_work slug, year, month, message_list, threadset
    # cache each thread
    thread_list = []
    threadset.collect do |thread|
      thread.cache
      thread_list << { :call_number => thread.call_number, :subject => thread.n_subject, :messages => thread.count }
    end

    # cache the message_list (for Threader) and thread_list (for Renderer)
    list = List.new slug
    list.cache_message_list year, month, message_list
    list.cache_thread_list  year, month, thread_list
  end

  def queue_renderer slug, year, month, threadset
    thread_q = Queue.new :render_thread
    threadset.each { |thread| thread_q.add :slug => slug, :year => year, :month => month, :call_number => thread.call_number }
    Queue.new(:render_month).add :slug => slug, :year => year, :month => month
    Queue.new(:render_list).add :slug => slug
  end
end

Threader.new.run if __FILE__ == $0
