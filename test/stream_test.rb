require "helper"

class AudioPlayback::StreamTest < Minitest::Test

  context "Stream" do

    setup do
      @path = "test/media/1-mono-44100.wav"
      @sound = AudioPlayback::Sound.load(@path)
      @output = AudioPlayback::Output.by_id(0)
    end

    context "#exit_callback" do

      setup do
        @stream = AudioPlayback::Stream.new(@output)
        @stream.expects(:close).once
      end

      teardown do
        @stream.unstub(:close)
      end

      should "initialize exit callback" do
        assert @stream.send(:exit_callback)
      end

    end

  end

end
