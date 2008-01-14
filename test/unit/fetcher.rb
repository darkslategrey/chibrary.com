require File.dirname(__FILE__) + '/../test_helper'
require 'fetcher'

class FetcherTest < Test::Unit::TestCase
  def test_setup
    Net::POP3.expects(:new).returns(mock(
      :open_timeout= => nil,
      :read_timeout= => nil,
      :start => nil,
      :n_mails => 0
    ))
    f = Fetcher.new(0, 0)
    f.setup
  end

  def test_setup_server_down
    Net::POP3.expects(:new).raises(Timeout::Error, "execution expired")
    f = Fetcher.new(0, 0)
    assert_raises(Timeout::Error, "execution expired") do
      f.setup
    end
  end

  def test_teardown
    f = Fetcher.new(0, 0)
    nil.expects(:finish)
    f.teardown
  end

  def test_acquire
    f = Fetcher.new(0, 0)
    mail = mock("mail", :delete => true)
    mail.expects(:mail).at_least(1).returns("Test message")
    nil.expects(:each_mail).yields(mail)
    f.acquire { |mail, overwrite| assert_equal 'Test message', mail }
  end

  def test_sequence_exhaustion
    f = Fetcher.new(0, 2 ** 20)
    mail = mock("mail")
    mail.expects(:mail).at_least(1).returns("Test Message")
    nil.expects(:each_mail).yields(mail)
    f.acquire { |mail, overwrite| f.store mail }
  end

  def test_source
    assert_equal 'subscription', Fetcher.new(0, 0).source
  end
end
