require_relative '../test_helper'
include Enparser

describe Extractor do

	before do
		@extractor = Extractor.new
	end

	it 'must extract words' do
    @extractor.extract('Hello, World!')
		@extractor.extracted?('Hello').must_equal true
		@extractor.extracted?('worlD').must_equal true
		@extractor.words.size.must_equal 2
	end

  def debug_print
    puts "-= debug print =-\nwords: #{@extractor.words}"
    puts "forms: #{@extractor.forms}"
    puts "skips: #{@extractor.skips}"
  end

  it 'must extract lemma and hold forms' do
    @extractor.extract 'What are you doing?'
    @extractor.extracted?('What').must_equal true
    @extractor.extracted?('be').must_equal true
    @extractor.extracted?('are').must_equal true
    @extractor.extracted?('you').must_equal true
    @extractor.extracted?('doing').must_equal true
    @extractor.extracted?('do').must_equal true
  end

  it 'must skip lemmas by word' do
    @extractor.skip_line 'be do'
    @extractor.skip?('be').must_equal true
    @extractor.skip?('am').must_equal true
    @extractor.skip?('is').must_equal true
    @extractor.skip?('are').must_equal true

    @extractor.extract 'What are you doing?'
    @extractor.extracted?('doing').must_equal false
    @extractor.extracted?('are').must_equal false
    @extractor.extracted?('what').must_equal true
    @extractor.extracted?('you').must_equal true
  end

  it 'must skip default word list' do
    @extractor.load_skip_deafult
    @extractor.extract 'This article wasn\'t interested'
    @extractor.extracted?('This').must_equal false
    @extractor.extracted?('this').must_equal false
    @extractor.extracted?('wasn\'t').must_equal false
    @extractor.extracted?('article').must_equal true
    @extractor.extracted?('interested').must_equal true
  end

  it '#each must iterate by |word count forms|' do
    @extractor.extract "What are you doing here my dear? I don't know."
    check_result = [
      "what;1;",
      "be;1;are",
      "you;1;",
      "do;2;doing",
      "here;1;",
      "my;1;",
      "dear;1;",
      "know;1;",
      "i;1;"]
    extracted = []
		@extractor.each do |word, count, forms|
      extracted << "#{word};#{count};#{forms}"
		end
    extracted.each {|e| check_result.include?(e).must_equal true}
  end

end
