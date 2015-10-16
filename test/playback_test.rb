require "helper"

class AudioPlayback::PlaybackTest < Minitest::Test

  context "Playback" do

    setup do
      @path = "test/media/1-mono-44100.wav"
      @sound = AudioPlayback::Sound.load(@path)
      @output = AudioPlayback::Output.by_id(0)
    end

    context ".play" do

      setup do
        AudioPlayback::Stream.any_instance.expects(:start).once.returns(true)
      end

      teardown do
        AudioPlayback::Stream.any_instance.unstub(:start)
      end

      should "start playback" do
        @playback = AudioPlayback::Playback.play(@sound, @output)
        refute_nil @playback
        assert_kind_of AudioPlayback::Playback::Action, @playback
      end

    end

    context "#start" do

      setup do
        @playback = AudioPlayback::Playback.new(@sound, @output)
        AudioPlayback::Stream.any_instance.expects(:start).once.returns(true)
      end

      teardown do
        AudioPlayback::Stream.any_instance.unstub(:start)
      end

      should "start playback" do
        @result = @playback.start
        assert_kind_of AudioPlayback::Playback::Action, @result
      end

    end

    context "#block" do

      setup do
        @playback = AudioPlayback::Playback.new(@sound, @output)
        AudioPlayback::Stream.any_instance.expects(:block).once.returns(true)
      end

      teardown do
        AudioPlayback::Stream.any_instance.unstub(:block)
      end

      should "defer to stream" do
        assert @playback.block
      end

    end

    context "#report" do

      setup do
        @logger = Object.new
        @playback = AudioPlayback::Playback.new(@sound, @output)
        @logger.expects(:puts).at_least_once
      end

      teardown do
        @logger.unstub(:puts)
      end

      should "do logging" do
        assert @playback.report(@logger)
      end

    end

    context "#data_size" do

      setup do
        @playback = AudioPlayback::Playback.new(@sound, @output)
        @size = @playback.data_size
        @metadata_size = AudioPlayback::Playback::METADATA.count * AudioPlayback::Playback::FRAME_SIZE.size
        @sound_data_size = (@sound.size * @sound.num_channels) * AudioPlayback::Playback::FRAME_SIZE.size
        @total_size = @metadata_size + @sound_data_size
      end

      should "have data size" do
        refute_nil @size
        assert @size > 0
      end

      should "be larger than sound file data size" do
        assert @size > @sound_data_size
      end

      should "be equal to sound file plus metadata size" do
        assert_equal @total_size, @size
      end

    end

  end

end
