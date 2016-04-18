$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'enparser'

require 'minitest/autorun'


def capture_stdout
  real_stdout = $stdout
  $stdout = StringIO.new
  yield
  $stdout.string
ensure
  $stdout = real_stdout
end

module Kernel
  def suppress_warnings
    original_verbosity = $VERBOSE
    $VERBOSE = nil
    result = yield
    $VERBOSE = original_verbosity
    return result
  end
end
