$:.unshift(File.join("..", "lib"))

require "minitest/autorun"
require "mocha/test_unit"
require "shoulda-context"
require "audio-playback"

class MockOutput

  attr_reader :num_channels

  def initialize(id, options = {})
    @id = id
    @num_channels = options[:num_channels] || 2
  end

  def latency
    1
  end

end

class MockStream

  def initialize(output)
    @output = output
  end

end
