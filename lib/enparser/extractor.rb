# encoding: UTF-8
require 'lemmatizer'

module Enparser

  class Extractor

    attr_reader :words
    attr_reader :forms
    attr_reader :skips

    def initialize
      @words = {}
      @skips = {}
      @forms = {}
      @lmlzr = Lemmatizer.new
    end

    def skip?(word)
      !@skips[@lmlzr.lemma(word.downcase)].nil?
    end

    def split_by_word(line)
      line.scrub!
      words = line.scan(/[a-zA-Z]+\-?\'?[a-zA-Z]*/)
      # FIXME: can't -> ca
      words.each {|w|
        w.gsub!(/^can't/, 'can')
        w.gsub!(/^won't/, 'will')
        w.gsub!(/(\'m|\'s|\'re|\'d|\'ve|\'ll|n\'t)$/, '')}
      words
    end

    def skip_line(line)
      split_by_word(line.downcase).each {|w| @skips[@lmlzr.lemma(w)] = 0}
    end

    def extract_word(word)
      lemma = @lmlzr.lemma(word)
      return if skip?(lemma)
      @words[lemma] = 0 if @words[lemma].nil?
      @forms[lemma] = {} if @forms[lemma].nil?
      @words[lemma] += 1
      @forms[lemma][word] = 0 unless lemma.eql?(word)
    end

    def extracted?(word)
      w = word.downcase
      lemma = @lmlzr.lemma(w)
      return false if @words[lemma].nil?
      aforms = Array.new(@forms[lemma].keys)
      aforms << lemma
      return aforms.include?(w)
    end

    def extract(line)
      split_by_word(line).each {|w| extract_word(w.downcase)}
    end

    def load_skip_file(file_pattern)
      skipfiles = Dir.glob(file_pattern.split(';')).flatten.uniq
      skipfiles.each do |f|
        File.foreach(f) {|l| skip_line(l)}
      end
    end

    def parse_files(file_pattern)
      files = Dir.glob(file_pattern.split(';')).flatten.uniq
      files.each do |f|
        File.foreach(f) {|l| extract(l)}
      end
    end

    def sort!
      @words = @words.sort_by(&:last).to_h
    end

    # accept block with |word, count, forms|
    def each
      return unless block_given?
      sort!
      @words.each {|k, v| yield(k, v, @forms[k].keys.join(', ')) }
    end

    # TODO make some lists and put it into data directory
    def load_skip_deafult
      load_skip_file('word/*')
    end
# %{
# I he she it you we they
# my me him his her its us our their your yours them self
# a an the this that these those all that's
# here there
# be do have will not want
# can can't cannot could couldn't must mustn't should shouldn't may might mayn't mightn't won't would
# I'm he's she's it's we're they're i've they've he'd she'd we've
# isn't aren't don't doesn't didn't weren't wasn't haven't hadn't hasn't
# who who's what what's where when whose which how why
# if then else unless for from till until while begin end start finish though although because true false any
# and also or yes no not for to at as of on by but about just in with so too up down left right bottom before after back out more less than
# one two three four five six seven eight nine ten eleven twelf
# first last second third
# now day eve today tomorrow yesterday
# month january february march april may june july august september october november december
# season year winter spring summer autumn
# week Monday Tuesday Wednesday Thursday Friday Saturday Sunday
# mr. ms.
# go try know let make take say find need see get tell think mean ask time move call buy talk thank use
# every each very
# ever never even
# name thing anything nothing other another
# gonna wanna
# }.each_line {|l| skip_line(l)}
#     end
  end

end
