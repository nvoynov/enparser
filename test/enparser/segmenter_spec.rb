require_relative '../test_helper'
include Enparser

describe Segmenter do

  TEST_FILE = get_data_path + '/test.txt'
  TEST_REGX = get_data_path + '/test.rex'

  before do
    @segmenter = Segmenter.new
  end

  it '#completed? must detect completed sentence' do
    @segmenter.completed?('My name is Alex.').must_equal true
    @segmenter.completed?('My name is Alex!').must_equal true
    @segmenter.completed?('My name is Alex?').must_equal true
    @segmenter.completed?('My name is Alex').must_equal false
    @segmenter.completed?('C.I.A.').must_equal false
    @segmenter.completed?('Mr. John said...').must_equal false
    @segmenter.completed?('Mr. John said... bla').must_equal false
  end

  def add_subtitle_skip_patterns
    # add skip patterns for subtitles
    @segmenter.add_skip_pattern '^\n$'
    @segmenter.add_skip_pattern '^(\d)+$'
    @segmenter.add_skip_pattern '^\d{2}:\d{2}:\d{2},\d{3} --> \d{2}:\d{2}:\d{2},\d{3}$'
  end

  describe 'skip patters' do
    it 'must skip lines by matching to patterns' do
      add_subtitle_skip_patterns
      @segmenter.skip?("\n").must_equal true
      @segmenter.skip?("1").must_equal true
      @segmenter.skip?("00:00:01,202 --> 00:00:02,594").must_equal true
    end

    it 'must load skip patterns from file' do
      File.open(TEST_REGX, 'w') do |f|
        f.puts '^\n$'
        f.puts '^(\d)+$'
        f.puts '^\d{2}:\d{2}:\d{2},\d{3} --> \d{2}:\d{2}:\d{2},\d{3}$'
      end
      @segmenter.load_skip_patters(TEST_REGX)
      @segmenter.skip?("\n").must_equal true
      @segmenter.skip?("1").must_equal true
      @segmenter.skip?("00:00:01,202 --> 00:00:02,594").must_equal true
    end
  end

  describe 'segment' do
    it 'must segment text' do
      segments = @segmenter.segment "My name is Alex Parrish. I'm an FBI agent."
      segments.first.must_equal "My name is Alex Parrish."
      segments.last.must_equal "I'm an FBI agent."
    end

    it 'must segment stream' do
      text = StringIO.new
      text.puts "My name is Alex Parrish."
      text.puts "I'm an FBI agent."
      text.puts "In July, a terrorist blew"
      text.puts "up Grand Central Terminal,"
      text.puts "but before that, I was still a trainee."
      text.pos = 0

      segments = []
      @segmenter.segment_stream(text) {|s| segments << s}
      segments[0].must_equal "My name is Alex Parrish."
      segments[1].must_equal "I'm an FBI agent."
      segments[2].must_equal "In July, a terrorist blew up Grand Central Terminal, but before that, I was still a trainee."
    end

    it 'must segment file' do
      File.open(TEST_FILE, 'w') do |f|
        f.puts "My name is Alex Parrish."
        f.puts "I'm an FBI agent."
        f.puts "In July, a terrorist blew"
        f.puts "up Grand Central Terminal,"
        f.puts "but before that, I was still a trainee."
      end

      segments = []
      @segmenter.segment_file(TEST_FILE) {|s| segments << s}
      segments[0].must_equal "My name is Alex Parrish."
      segments[1].must_equal "I'm an FBI agent."
      segments[2].must_equal "In July, a terrorist blew up Grand Central Terminal, but before that, I was still a trainee."
    end
  end
end
