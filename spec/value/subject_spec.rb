require_relative '../rspec'
require_relative '../../value/subject'

module Chibrary

describe Subject do
  REPLY_SUBJECTS = ["Re: foo", "RE: foo", "RE[9]: foo", "re(9): foo", "re:foo", "re: Re: foo", "fwd: foo", "Fwd: foo", "Fwd[14]: foo", "Re: Fwd: RE: fwd(3): foo", "fw: foo"]

  describe '#reply?' do
    it 'sees reply subjects as replies' do
      REPLY_SUBJECTS.each do |str|
        subject = Subject.new str
        expect(subject).to be_reply
      end
    end

    it 'does not consider a plain subject a reply' do
      expect(Subject.new 'Foo').to_not be_reply
    end

    it 'does not consider everything with "re" a reply' do
      expect(Subject.new 're-finance').to_not be_reply
    end

    it 'does not consider blank subjects a reply' do
      expect(Subject.new('')).to_not be_reply
    end
  end

  describe '#normalized' do
    it 'removes reply/fwd indicators' do
      REPLY_SUBJECTS.each do |str|
        expect(Subject.new(str).normalized).to eq('foo')
      end
    end

    it 'does not change subjects without reply/fwd indicators' do
      expect(Subject.new("foo").normalized).to eq('foo')
    end

    it 'does not remove every instance of "re"' do
      expect(Subject.new("re-foo").normalized).to eq('re-foo')
    end

    it 'passes through blank subjects' do
      expect(Subject.new('').normalized).to eq('')
    end
  end

  describe '#gunk_length' do
    it "is 0 for subjects with none of that" do
      expect(Subject.new('foo').gunk_length).to eq(0)
    end

    it "is the length of the re/fwd gunk including trailing spaces" do
      expect(Subject.new('re:  foo').gunk_length).to eq(5)
    end

    it "is length of all re/fwd gunk" do
      expect(Subject.new('re: fwd: foo').gunk_length).to eq(9)
    end
  end

  describe '#to_s' do
    it 'passes through original subjects' do
      expect(Subject.new('Re: foo').to_s).to eq('Re: foo')
    end

    it 'passes through blank subjects' do
      expect(Subject.new('').to_s).to eq('')
    end
  end

  describe '#==' do
    it 'considers equivalent subjects ==' do
      expect(Subject.new('a')).to eq(Subject.new('a'))
    end

    it 'considers equivalent strings ==' do
      expect(Subject.new('a')).to eq('a')
    end

    it 'does not normalize in the comparison' do
      expect(Subject.new('a')).to_not eq('Re: a')
    end
  end
end

end # Chibrary
