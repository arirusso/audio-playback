require "helper"

class AudioPlayback::PlaybackTest < Minitest::Test

  context "Playback" do

    setup do
      @path = "test/media/1-mono-44100.wav"
      @sound = AudioPlayback::Sound.load(@path)
      @output = AudioPlayback::Device::Output.by_id(0)
    end

    context ".play" do

      teardown do
        AudioPlayback::Device::Stream.any_instance.unstub(:start)
      end

      context "without truncation" do

        setup do
          AudioPlayback::Device::Stream.any_instance.expects(:start).once.returns(true)
          @playback = AudioPlayback::Playback.play(@sound, @output)
        end

        should "start playback" do
          refute_nil @playback
          assert_kind_of AudioPlayback::Playback::Action, @playback
        end

        should "not have truncation params" do
          assert_nil @playback.truncate
        end

      end

      context "with truncation" do

        setup do
          AudioPlayback::Device::Stream.any_instance.expects(:start).once.returns(true)
          @playback = AudioPlayback::Playback.play(@sound, @output, :seek => 0.8, :duration => 2)
        end

        should "start playback" do
          refute_nil @playback
          assert_kind_of AudioPlayback::Playback::Action, @playback
        end

        should "have truncation params" do
          refute_nil @playback.truncate
          assert_kind_of Hash, @playback.truncate
          refute_nil @playback.truncate[:seek]
          refute_nil @playback.truncate[:duration]
        end

      end

    end

    context "#start" do

      setup do
        @playback = AudioPlayback::Playback.new(@sound, @output)
        AudioPlayback::Device::Stream.any_instance.expects(:start).once.returns(true)
      end

      teardown do
        AudioPlayback::Device::Stream.any_instance.unstub(:start)
      end

      should "start playback" do
        @result = @playback.start
        assert_kind_of AudioPlayback::Playback::Action, @result
      end

    end

    context "#block" do

      setup do
        @playback = AudioPlayback::Playback.new(@sound, @output)
        AudioPlayback::Device::Stream.any_instance.expects(:block).once.returns(true)
      end

      teardown do
        AudioPlayback::Device::Stream.any_instance.unstub(:block)
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

    context "#number_of_seconds_to_number_of_frames" do

      setup do
        @playback = AudioPlayback::Playback.new(@sound, @output)
      end

      should "convert seconds to frames" do
        assert_equal 3 * 44100, @playback.send(:number_of_seconds_to_number_of_frames, 3)
        assert_equal 10 * 44100, @playback.send(:number_of_seconds_to_number_of_frames, 10)
        assert_equal 30 * 44100, @playback.send(:number_of_seconds_to_number_of_frames, 30)
        assert_equal 5000 * 44100, @playback.send(:number_of_seconds_to_number_of_frames, 5000)
      end

    end

    context "#truncate_requested?" do

      context "with truncation" do

        setup do
          @playback = AudioPlayback::Playback.new(@sound, @output)
        end

        should "have truncation params" do
          assert @playback.send(:truncate_requested?, :seek => 3, :duration => 2)
        end

      end

      context "without truncation" do

        setup do
          @playback = AudioPlayback::Playback.new(@sound, @output)
        end

        should "have truncation params" do
          refute @playback.send(:truncate_requested?, {})
        end

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
