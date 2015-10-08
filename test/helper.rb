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

module TestHelper

  DEFAULT_OUTPUT_ID = 0
  OUTPUT_INFO = [
    {
      :defaultHighOutputLatency => 2.3,
      :maxOutputChannels => 1,
      :name => "Test Output 1"
    },
    {
      :defaultHighOutputLatency => 3.2,
      :maxOutputChannels => 2,
      :name => "Test Output 2"
    }
  ]

  def self.stub_portaudio
    FFI::PortAudio::API.stubs(:Pa_GetDeviceCount).returns(2)
    FFI::PortAudio::API.expects(:Pa_GetDeviceInfo).with(0).at_least_once.returns(TestHelper::OUTPUT_INFO[0])
    FFI::PortAudio::API.expects(:Pa_GetDeviceInfo).with(1).at_least_once.returns(TestHelper::OUTPUT_INFO[1])
    FFI::PortAudio::API.stubs(:Pa_GetDefaultOutputDevice).returns(TestHelper::DEFAULT_OUTPUT_ID)
    FFI::PortAudio::API.stubs(:Pa_Initialize).returns(true)
    FFI::PortAudio::API.stubs(:Pa_Terminate).returns(true)
  end

end

TestHelper.stub_portaudio
