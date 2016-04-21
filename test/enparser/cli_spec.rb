# encoding: UTF-8
require_relative '../test_helper'
include Enparser

describe Cli do

  FILE_NAME = get_data_path + '/test.srt'
  SKIP_WORD = get_data_path + '/test.skip.txt'
  SKIP_REGX = get_data_path + '/test.rex'

  CLEAR_SEGMENTED = %(My name is Alex Parrish.
I'm an FBI agent.
In July, a terrorist blew up Grand Central Terminal, but before that, I was still a trainee.
).freeze

  RIGHT_SEGMENTED = %(1 00:00:01,202 --> 00:00:02,594 My name is Alex Parrish.
2 00:00:02,720 --> 00:00:03,827 I'm an FBI agent.
3 00:00:03,944 --> 00:00:06,319 In July, a terrorist blew up Grand Central Terminal,  4 00:00:06,320 --> 00:00:08,346 but before that, I was still a trainee.
).freeze

  EXTRACTED_WORDS1 = %(alex 1 parrish 1 fbi 1 agent 1 terrorist 1 blow 1 (blew)
grand 1 central 1 terminal 1 still 1 trainee 1).freeze

EXTRACTED_WORDS2 = %(my 1
name 1
still 1
alex 1
parrish 1
that 1
an 1
fbi 1
agent 1
in 1
july 1
before 1
terrorist 1
blow 1 (blew)
up 1
grand 1
central 1
terminal 1
but 1
trainee 1
i 2
be 2 (is, was)
a 2
).freeze


EXTRACTED_WORDS3 = %(agent 1
terrorist 1
blow 1 (blew)
still 1
trainee 1
).freeze

  # enparse segment FILE_NAME [SKIP_PATTERNS]
  describe '#segment commnad' do

    it 'must segment FILE_NAME' do
      stdout = capture_stdout { Cli.start(['segment', FILE_NAME]) }
      stdout.must_equal RIGHT_SEGMENTED
    end

    it 'must segment FILE_NAME SKIP_PATTERNS' do
      stdout = capture_stdout { Cli.start(['segment', FILE_NAME, SKIP_REGX]) }
      stdout.must_equal CLEAR_SEGMENTED
    end

  end

  # enparse lemmatize FILE_NAME [SKIP_SOURCES] [DELIMITER]
  # -d, [--not-load-default], [--no-not-load-default]
  # -s, [--strict-by-lemmas], [--no-strict-by-lemmas]
  describe '#lemmatize command' do

    it 'must lemmatize FILE_NAME' do
      stdout = capture_stdout { Cli.start(['lemmatize', FILE_NAME])}
      stdout.each_line {
        |l| EXTRACTED_WORDS1.include?(l.chomp).must_equal true
      }
    end

    # --no-load-default
    it 'must lemmatize FILE_NAME -d' do
      stdout = capture_stdout { Cli.start(['lemmatize', FILE_NAME, '-d=false'])}
      stdout.each_line {
        |l| EXTRACTED_WORDS2.include?(l.chomp).must_equal true
      }
    end

    it 'must lemmatize FILE_NAME SKIP_SOURCES' do
      stdout = capture_stdout { Cli.start(['lemmatize', FILE_NAME, SKIP_WORD])}
      stdout.each_line {
        |l| EXTRACTED_WORDS3.include?(l.chomp).must_equal true
      }
    end

    # separator
    it 'must lemmatize FILE_NAME -s' do
      stdout = capture_stdout { Cli.start(['lemmatize', FILE_NAME, SKIP_WORD, '-s', ";"])}
      check_words = EXTRACTED_WORDS3.gsub(' ', ';')
      stdout.each_line { |l| check_words.include?(l.chomp).must_equal true }
    end

    # only lemma
    it 'must lemmatize FILE_NAME -l' do
      stdout = capture_stdout { Cli.start(['lemmatize', FILE_NAME, SKIP_WORD, '-l'])}
      check_words = "terrorist blow still"
      stdout.each_line { |l| check_words.include?(l.chomp).must_equal true }
    end

  end
end
