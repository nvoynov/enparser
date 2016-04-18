# encoding: UTF-8
require 'thor'
require_relative 'segmenter'

module Enparser
  class Cli < Thor
    include Thor::Actions

    desc 'segment FILE_NAME [SKIP_PATTERNS]', 'Segment file content to STDOUT.'
    def segment(file_name, skip_patterns = '')
      segmenter = Enparser::Segmenter.new
      segmenter.load_skip_patters(skip_patterns) unless skip_patterns.empty?
      segmenter.segment_file(file_name) { |s| puts s }
    end

    # TODO: known, unknown .... load-known load-default-known strict-by-lemma
    desc 'lemmatize FILE_NAME [SKIP_SOURCES]', 'Extract words, lemma, forms and frequency to STDOUT'
    method_option :separator, aliases: '-s', default: ' ', desc: 'Separator between lemma, count and word forms'
    method_option 'load-default', aliases: '-d', type: :boolean, default: true, desc: 'Skip loading skip_default_set.'
    method_option 'strict-by-lemmas', aliases: '-l', type: :boolean, default: false, desc: 'Output only lemmas.'
    def lemmatize(file_name, skip_sources = '')
      lemmatizer = Enparser::Extractor.new
      lemmatizer.load_skip_deafult if options['load-default']
      lemmatizer.load_skip_file(skip_sources) unless skip_sources.empty?
      lemmatizer.parse_file(file_name)
      sep = options[:separator]
      lemmatizer.each do |word, count, forms|
        line = String.new(word)
        unless options['strict-by-lemmas']
          line << "#{sep}#{count}"
          line << "#{sep}(#{forms})" unless forms.empty?
        end
        puts line
      end
    end
  end
end
