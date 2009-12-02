require 'test_helper'
require 'threader'
require 'message'

class ThreaderTest < ActiveSupport::TestCase
  fixtures :message

  def setup
    $stdout.expects(:puts).at_least(0)
    @thread_q = mock("thread_q")
    Queue.expects(:new).returns(@thread_q)
  end

  def test_run_empty
    @thread_q.expects(:work).returns nil
    # threader should exit cleanly, doing nothing
    Threader.new.run
  end

  def test_run_removed
    t = new_threader

    # one message in cache, none in list
    list = mock("list")
    list.expects(:cached_message_list).returns(["1@example.com"])
    list.expects(:fresh_message_list).returns([])
    List.expects(:new).returns(list)
    ts = mock
    ThreadSet.expects(:new).returns(ts)

    t.expects(:cache_work).with('example', '2008', '08', [], ts)
    t.run
  end

  def test_run_add_message
    t = new_threader
    list = mock("list")
    list.expects(:cached_message_list).returns(["1@example.com"])
    list.expects(:fresh_message_list).returns(["1@example.com", "2@example.com"])
    List.expects(:new).returns(list)

    message = mock("message")
    $archive.expects(:[]).with('list/example/message/2008/08/2@example.com').returns(message)
    ts = mock("threadset")
    ts.expects(:<<).with(message)
    ThreadSet.expects(:month).returns(ts)

    t.expects(:cache_work)
    t.run
  end

  def test_run_multiple_jobs
    t = Threader.new

    # two empty jobs
    job1 = Job.new :thread, :slug => 'example', :year => '2008', :month => '07'
    list1 = mock("list1")
    list1.expects(:cached_message_list).returns([])
    list1.expects(:fresh_message_list).returns([])

    job2 = Job.new :thread, :slug => 'example', :year => '2008', :month => '08'
    list2 = mock("list2")
    list2.expects(:cached_message_list).returns([])
    list2.expects(:fresh_message_list).returns([])

    @thread_q.expects(:work).multiple_yields(job1, job2)
    List.expects(:new).times(2).returns(list1).then.returns(list2)

    t.run
  end

  def test_cache_work_empty
    slug, year, month = 'example', '2007', '08'

    message_list = ['1@example.com']
    threadset = mock("threadset", :rejoin_splits => true)

    list = mock("list")
    list.expects(:cache_message_list).with("2007", "08", message_list)
    List.expects(:new).returns(list)

    Queue.expects(:new).with(:publish).returns(mock('publish_q', :add => nil))

    Threader.new.cache_work slug, year, month, message_list, threadset
  end

  def test_cache_work
    slug, year, month = 'example', '2007', '08'

    message_list = ['1@example.com']
    threadset = mock("threadset", :rejoin_splits => true)

    list = mock("list")
    list.expects(:cache_message_list).with("2007", "08", message_list)
    List.expects(:new).returns(list)

    Queue.expects(:new).with(:publish).returns(mock('publish_q', :add => nil))

    t = Threader.new
    t.cache_work slug, year, month, message_list, threadset
  end

  private
  def new_threader
    t = Threader.new
    job = Job.new :thread, :slug => 'example', :year => '2008', :month => '08'
    @thread_q.expects(:work).yields(job)
    t
  end
end
