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
        assert_kind_of AudioPlayback::Playback, @playback
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
        assert_kind_of AudioPlayback::Playback, @result
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
        @logger.expects(:puts).once
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

    context "#frames" do

      setup do
        @playback = AudioPlayback::Playback.new(@sound, @output)
      end

      should "have the correct number of frames" do
        assert_equal @sound.size + AudioPlayback::Playback::METADATA.size, @playback.frames.size
      end

      should "be the correct format" do
        assert @playback.frames.all? do |frame|
          if frame.kind_of?(Array)
            frame.all? { |num| num.is_a?(Float) }
          else
            frame.is_a?(Float)
          end
        end
      end

    end

    context "#ensure_structure" do

      context "sound has same number of channels as output" do

        context "mono file, mono output" do

          setup do
            @path = "test/media/1-mono-44100.wav"
            @file = AudioPlayback::File.new(@path)
            @sound = AudioPlayback::Sound.new(@file)
            @output = MockOutput.new(1, :num_channels => 1)
            @playback = AudioPlayback::Playback.new(@sound, @output, :stream => MockStream.new(@output))
            @data = @sound.data
            @frames = @playback.frames.slice(AudioPlayback::Playback::METADATA.size..-1)
          end

          should "have two channels of valid data" do
            refute_nil @frames
            assert @frames.kind_of?(Array)
            refute_empty @frames
            assert @frames.all? { |frame_channels| frame_channels.count == @output.num_channels }
            assert @frames.all? { |frame_channels| frame_channels.count == @sound.num_channels }
            assert @frames.all? { |frame_channels| frame_channels.all? { |frame| frame.kind_of?(Float) } }
          end

        end

        context "stereo file, stereo output" do

          setup do
            @path = "test/media/1-stereo-44100.wav"
            @file = AudioPlayback::File.new(@path)
            @sound = AudioPlayback::Sound.new(@file)
            @output = MockOutput.new(1, :num_channels => 2)
            @playback = AudioPlayback::Playback.new(@sound, @output, :stream => MockStream.new(@output))
            @data = @sound.data
            @frames = @playback.frames.slice(AudioPlayback::Playback::METADATA.size..-1)
          end

          should "have one channel of valid data" do
            refute_nil @frames
            assert @frames.kind_of?(Array)
            refute_empty @frames
            assert @frames.all? { |frame_channels| frame_channels.kind_of?(Array) }
            assert @frames.all? { |frame_channels| frame_channels.count == @output.num_channels }
            assert @frames.all? { |frame_channels| frame_channels.count == @sound.num_channels }
            assert @frames.all? { |frame_channels| frame_channels.all? { |frame| frame.kind_of?(Float) } }
          end

        end

      end

      context "sound has different number of channels than output" do

        context "mono file, stereo output" do

          setup do
            @path = "test/media/1-mono-44100.wav"
            @file = AudioPlayback::File.new(@path)
            @sound = AudioPlayback::Sound.new(@file)
            @output = MockOutput.new(1, :num_channels => 2)
            @playback = AudioPlayback::Playback.new(@sound, @output, :stream => MockStream.new(@output))
            @data = @sound.data
            @frames = @playback.frames.slice(AudioPlayback::Playback::METADATA.size..-1)
          end

          should "have two channels of valid data" do
            refute_nil @frames
            assert @frames.kind_of?(Array)
            refute_empty @frames
            assert @frames.all? { |frame_channels| frame_channels.count == @output.num_channels }
            refute @frames.any? { |frame_channels| frame_channels.count == @sound.num_channels }
            assert @frames.all? { |frame_channels| frame_channels.all? { |frame| frame.kind_of?(Float) } }
          end

        end

        context "stereo file, mono output" do

          setup do
            @path = "test/media/1-stereo-44100.wav"
            @file = AudioPlayback::File.new(@path)
            @sound = AudioPlayback::Sound.new(@file)
            @output = MockOutput.new(1, :num_channels => 1)
            @playback = AudioPlayback::Playback.new(@sound, @output, :stream => MockStream.new(@output))
            @data = @sound.data
            @frames = @playback.frames.slice(AudioPlayback::Playback::METADATA.size..-1)
          end

          should "have one channel of valid data" do
            refute_nil @frames
            assert @frames.kind_of?(Array)
            refute_empty @frames
            assert @frames.all? { |frame_channels| frame_channels.kind_of?(Array) }
            assert @frames.all? { |frame_channels| frame_channels.count == @output.num_channels }
            refute @frames.any? { |frame_channels| frame_channels.count == @sound.num_channels }
            assert @frames.all? { |frame_channels| frame_channels.all? { |frame| frame.kind_of?(Float) } }
          end

        end

      end

    end

  end

end
