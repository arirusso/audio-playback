require "helper"

class AudioPlayback::Playback::StreamDataTest < Minitest::Test

  context "StreamData" do

    context "#to_pointer" do

      setup do
        @path = "test/media/1-mono-44100.wav"
        @file = AudioPlayback::File.new(@path)
        @sound = AudioPlayback::Sound.new(@file)
        @output = MockOutput.new(1, :num_channels => 1)
        @playback = AudioPlayback::Playback.new(@sound, @output, :stream => MockStream.new(@output))
        @data = @playback.data
      end

      should "return a pointer" do
        refute_nil @data
        assert_kind_of FFI::Pointer, @data
      end

    end

  end

end
