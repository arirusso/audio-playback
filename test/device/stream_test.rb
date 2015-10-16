require "helper"

class AudioPlayback::Device::StreamTest < Minitest::Test

  context "Stream" do

    setup do
      @path = "test/media/1-mono-44100.wav"
      @sound = AudioPlayback::Sound.load(@path)
      @output = AudioPlayback::Device::Output.by_id(0)
    end

    context "#exit_callback" do

      setup do
        @stream = AudioPlayback::Device::Stream.new(@output)
        @stream.expects(:close).once
      end

      teardown do
        @stream.unstub(:close)
      end

      should "initialize exit callback" do
        assert @stream.send(:exit_callback)
      end

    end

    context "#play" do

      setup do
        @stream = AudioPlayback::Device::Stream.new(@output)
        @playback = AudioPlayback::Playback.new(@sound, @output)
        @stream.expects(:report).once
        @stream.expects(:open_playback).once
        @stream.expects(:start).once
      end

      teardown do
        @stream.unstub(:report)
        @stream.unstub(:open_playback)
        @stream.unstub(:start)
      end

      should "return self" do
        assert_equal @stream, @stream.play(@playback)
      end

    end

  end

end
