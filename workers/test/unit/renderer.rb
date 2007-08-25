require File.dirname(__FILE__) + '/../test_helper'
require 'renderer'
require 'threading'
require 'message'

class RendererTest < Test::Unit::TestCase
  fixtures :message

  def setup
    $stdout.expects(:puts).at_least(0)
  end

  def test_get_job
    r = Renderer.new

    AWS::S3::Bucket.expects(:objects).returns(['renderer_queue/example_list/2008/08'])
    assert_equal 'renderer_queue/example_list/2008/08', r.get_job

    AWS::S3::Bucket.expects(:objects).returns([])
    assert_equal nil, r.get_job
  end

  def test_render_list
  end

  def test_render_month
  end

  def test_render_thread
    r = Renderer.new
    r.expects(:load_cache).with("example/thread/2007/08/00000000").returns("thread")
    r.expects(:render).with("thread", { :thread => "thread" }).returns("html")
    r.expects(:upload_page).with("example/2007/08/00000000", "html")
    r.render_thread "example", "2007", "08", "00000000"
  end

  def test_delete_thread
    r = Renderer.new
    sftp = mock
    sftp.expects(:remove).with("listlibrary.net/example/2007/08/00000000")
    Net::SFTP.expects(:start).yields(sftp)
    r.delete_thread "example", "2007", "08", "00000000"
  end

  def test_run_empty
    CachedHash.expects(:new).returns(mock)
    r = Renderer.new
    r.expects(:get_job).returns(nil)
    r.run
  end

  def test_run_list
    $stdout.expects(:puts).at_least_once
    CachedHash.expects(:new).returns(mock)
    r = Renderer.new
    r.expects(:get_job).times(2).returns(mock(:key => "render_queue/example", :delete => nil), nil)
    r.expects(:render_list).with("example")
    r.run
  end

  def test_run_month
    $stdout.expects(:puts).at_least_once
    render_queue = mock
    render_queue.expects(:[]=).with("example", '')
    CachedHash.expects(:new).returns(render_queue)
    r = Renderer.new
    r.expects(:get_job).times(2).returns(mock(:key => "render_queue/example/2007/08", :delete => nil), nil)
    r.expects(:render_month).with("example", "2007", "08")
    r.run
  end

  def test_run_thread_render
    $stdout.expects(:puts).at_least_once
    render_queue = mock
    render_queue.expects(:[]=).with("example/2007/08", '')
    CachedHash.expects(:new).returns(render_queue)
    r = Renderer.new
    r.expects(:get_job).times(2).returns(mock(:key => "render_queue/example/2007/08/00000000", :delete => nil), nil)
    AWS::S3::S3Object.expects(:exists?).with("list/example/thread/2007/08/00000000", "listlibrary_archive").returns(true)
    r.expects(:render_thread).with("example", "2007", "08", "00000000")
    r.run
  end

  def test_run_thread_delete
    $stdout.expects(:puts).at_least_once
    render_queue = mock
    render_queue.expects(:[]=).with("example/2007/08", '')
    CachedHash.expects(:new).returns(render_queue)
    r = Renderer.new
    r.expects(:get_job).times(2).returns(mock(:key => "render_queue/example/2007/08/00000000", :delete => nil), nil)
    AWS::S3::S3Object.expects(:exists?).with("list/example/thread/2007/08/00000000", "listlibrary_archive").returns(false)
    r.expects(:delete_thread).with("example", "2007", "08", "00000000")
    r.run
  end

  def test_render
    File::expects(:read).with("template/layout.haml").returns("layout")
    File::expects(:read).with("template/filename.haml").returns("filename")
    engine = mock
    engine.expects(:render).yields(mock)
    Haml::Engine.expects(:new).with("layout", :locals => { :a => "a", :title => "ListLibrary" }, :filename => "layout").returns(engine)
    Haml::Engine.expects(:new).with("filename", :locals => { :a => "a", :title => "ListLibrary" }, :filename => "filename").returns(mock(:render => nil))
    Renderer.new.render "filename", { :a => "a" }
  end

  def test_upload_page
    sftp = mock
    sftp.expects(:mkdir).with("listlibrary.net/path")
    sftp.expects(:mkdir).with("listlibrary.net/path/to")
    handle = mock
    sftp.expects(:open_handle).with("listlibrary.net/path/to/filename", "w").yields(handle)
    sftp.expects(:write).with(handle, "str").returns(mock(:code => 0))
    r = Renderer.new
    r.expects(:sftp_connection).yields(sftp)
    r.upload_page "path/to/filename", "str"
  end

  def test_sftp_connection
  end
end
