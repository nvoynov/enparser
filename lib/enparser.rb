require "enparser/version"
require "enparser/segmenter"
require "enparser/extractor"
require "enparser/cli"

module Enparser

  def self.root
    File.dirname __dir__
  end
  
end
