require_relative 'riak_storage'
require_relative '../container'

class ContainerStorage
  include RiakStorage

  attr_reader :container

  def initialize container
    @container = container
  end

  def extract_key
    slug = container.slug
    year = container.date.year
    month = container.date.month
    call_number = container.call_number

    "/#{slug}/#{year}/%02d/#{call_number}" % month
  end

  def self.build_key slug, year, month, call_number
    "/#{slug}/#{year}/%02d/#{call_number}" % month
  end

  def to_hash
    {
      message_id:  container.message_id,
      message_key: container.message_key,
      children:    container.children.map { |c| ContainerStorage.new(c).to_hash },
    }
  end

  def self.from_hash h
    container = Container.new h[:message_id], h[:message_key]
    h[:children].each do |child|
      container.adopt Container.deserialize(child)
    end
    container
  end

  def store
    return if container.empty_tree?
    bucket[extract_key] = to_hash
    container.cache_snippet
  end

  def self.find slug, year, month, call_number
    key = build_key(slug, year, month, call_number)
    hash = bucket[key]
    from_hash(hash)
  end
end