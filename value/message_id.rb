require_relative '../lib/core_ext/ice_nine_'

class MessageId
  prepend IceNine::DeepFreeze

  attr_reader :raw, :message_id

  def initialize raw
    @raw = (raw || '').to_s
  end

  def valid?
    !raw.empty? and raw.length <= 120 and has_id?
  end
  
  def has_id?
    raw =~ /\A<?[a-zA-Z0-9%+\-\.=_]+@[a-zA-Z0-9_\-\.]+>?\Z/
  end

  def extract_id
    @message_id ||= /^<?([^@]+@[^\>]+)>?/.match(raw)[1].chomp
  end

  def to_s
    if valid?
      extract_id
    else
      "[invalid or missing message id]"
    end
  end

  def == other
    other = MessageId.new(other)
    return false unless valid? and other.valid?
    to_s == other.to_s
  end

  def eql? other
    self == other
  end

  def encoding
    to_s.encoding
  end

  def hash
    to_s.hash
  end

  def inspect
    "#<MessageId:%x '%s'>" % [(object_id << 1), to_s]
  end

  def self.generate_for call_number
    raise ArgumentError, "Missing call number to generate MessageId" if (call_number || '') == ''

    new "#{call_number}@generated-message-id.chibrary.org"
  end

  def self.extract_or_generate str, call_number
    mid = new(str)
    return mid if mid.valid?
    return generate_for call_number
  end
end