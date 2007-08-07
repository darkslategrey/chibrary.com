#!/usr/bin/ruby

require 'net/pop'

require 'mail'
require 'filer'

class Fetcher
  def setup
    # create POP3 connection
    @pop = Net::POP3.new(MAIL_SERVER, MAIL_POP3_PORT)
    @pop.open_timeout = 300
    #pop.set_debug_output $stderr
    @pop.start(MAIL_USER, MAIL_PASSWORD)
    puts "#{@pop.n_mails} to process:"
  end

  def acquire
    pop.delete_all do |mail|
      yield mail
    end
  end

  def teardown
    pop.finish
  end
end


Fetcher.new.run if __FILE__ == $0
