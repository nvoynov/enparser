# encoding: UTF-8
require 'pragmatic_segmenter'

module Enparser

  class Segmenter

    def initialize
      @skips = []
    end

    def completed?(line)
      return false if /[^\.!?]+[\.!?]$/.match(line).nil? # end of sentence
      return false if /\w\.\w\.$/.match(line)       # abbrevation
      return false if /\.\.\.$/.match(line)         # ellipsis
      return true
    end

    def load_skip_patters(file_name)
      File.foreach(file_name) { |line| add_skip_pattern(line.chomp) }
    end

    def add_skip_pattern(pattern)
      @skips << Regexp.new(pattern)
    end

    def skip?(line)
      @skips.each {|t| return true unless t.match(line).nil?}
			return false
    end

    def strip!(line)
      line.scrub!
      line.gsub!(/<\/?[^>]*>/, "") # remove html tags
      line.strip!
      line.chomp!
      line
    end

    # @return [Array<String>]
    def segment(text)
      ps = PragmaticSegmenter::Segmenter.new(text: text)
      ps.segment.map(&:strip)
    end

    def parse_line(line)
      return '' if skip?(line)
      strip!(line)
      unless @previous.empty?
        line = @previous + ' ' + line
      end

      unless completed?(line)
        @previous = line
        line = ''
      else
        @previous = ''
      end
      line
    end

    # @param input [IO] must be opened
    # @param block [&block<String>]
    def segment_stream(input, &block)
      return unless block_given?
      @previous = ''
      input.each_line do |line|
        pl = parse_line(line)
        next if pl.empty?
        segment(pl).each {|s| yield(s)}
      end
    end

    def segment_file(file_name, &block)
      File.open(file_name) {|f| segment_stream(f) {|l| yield(l)}}
    end
  end

end
