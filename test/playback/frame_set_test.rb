require "helper"

class AudioPlayback::Playback::FrameSetTest < Minitest::Test

  context "FrameSet" do

    context "#truncate" do

      setup do
        @output = MockOutput.new(1, num_channels: 2)
        @sample_rate = 44100
      end

      context "with no truncation" do

        setup do
          @path = "test/media/1-mono-#{@sample_rate}.wav"
          @file = AudioPlayback::File.new(@path)
          @sound = AudioPlayback::Sound.new(@file)
          @playback = AudioPlayback::Playback.new(@sound, @output, stream: MockStream.new(@output))
          @data = @sound.data
          @frames = AudioPlayback::Playback::FrameSet.new(@playback).slice(AudioPlayback::Playback::METADATA.size..-1)
        end

        should "truncate to the corret length" do
          refute_nil @frames
          assert @frames.kind_of?(Array)
          refute_empty @frames
          assert @playback.size, @frames.length
        end

      end

      context "with seek" do

        context "mono file" do

          setup do
            @seek = 0.1
            @path = "test/media/1-mono-#{@sample_rate}.wav"
            @file = AudioPlayback::File.new(@path)
            @sound = AudioPlayback::Sound.new(@file)
            @playback = AudioPlayback::Playback.new(@sound, @output, stream: MockStream.new(@output), seek: @seek)
            @data = @sound.data
            @frames = AudioPlayback::Playback::FrameSet.new(@playback).slice(AudioPlayback::Playback::METADATA.size..-1)
          end

          should "truncate to the corret length" do
            refute_nil @frames
            assert @frames.kind_of?(Array)
            refute_empty @frames
            size = @playback.sounds.map(&:size).max - (@seek * @sample_rate).to_i
            assert size, @frames.length
          end

        end

        context "stereo file" do

          setup do
            @seek = 0.2
            @path = "test/media/1-stereo-#{@sample_rate}.wav"
            @file = AudioPlayback::File.new(@path)
            @sound = AudioPlayback::Sound.new(@file)
            @playback = AudioPlayback::Playback.new(@sound, @output, stream: MockStream.new(@output), seek: @seek)
            @data = @sound.data
            @frames = AudioPlayback::Playback::FrameSet.new(@playback).slice(AudioPlayback::Playback::METADATA.size..-1)
          end

          should "truncate to the correct length" do
            refute_nil @frames
            assert @frames.kind_of?(Array)
            refute_empty @frames
            size = assert @playback.sounds.map(&:size).max - (@seek * @sample_rate).to_i, @frames.length
            assert size, @frames.length
          end

        end

      end

      context "with seek and duration" do

        context "mono file" do

          setup do
            @seek = 0.3
            @duration = 0.4
            @path = "test/media/1-mono-#{@sample_rate}.wav"
            @file = AudioPlayback::File.new(@path)
            @sound = AudioPlayback::Sound.new(@file)
            @playback = AudioPlayback::Playback.new(@sound, @output, stream: MockStream.new(@output), seek: @seek, duration: @duration)
            @data = @sound.data
            @frames = AudioPlayback::Playback::FrameSet.new(@playback).slice(AudioPlayback::Playback::METADATA.size..-1)
          end

          should "truncate to the corret length" do
            refute_nil @frames
            assert @frames.kind_of?(Array)
            refute_empty @frames
            size = [@playback.sounds.map(&:size).max - (@seek * @sample_rate).to_i, (@duration * @sample_rate).to_i].min
            assert size, @frames.length
          end

        end

        context "stereo file" do

          setup do
            @seek = 0.5
            @duration = 0.6
            @path = "test/media/1-stereo-#{@sample_rate}.wav"
            @file = AudioPlayback::File.new(@path)
            @sound = AudioPlayback::Sound.new(@file)
            @playback = AudioPlayback::Playback.new(@sound, @output, stream: MockStream.new(@output), seek: @seek, duration: @duration)
            @data = @sound.data
            @frames = AudioPlayback::Playback::FrameSet.new(@playback).slice(AudioPlayback::Playback::METADATA.size..-1)
          end

          should "truncate to the correct length" do
            refute_nil @frames
            assert @frames.kind_of?(Array)
            refute_empty @frames
            size = [@playback.sounds.map(&:size).max - (@seek * @sample_rate).to_i, (@duration * @sample_rate).to_i].min
            assert size, @frames.length
          end

        end

      end

      context "with duration" do

        context "mono file" do

          setup do
            @duration = 0.7
            @path = "test/media/1-mono-#{@sample_rate}.wav"
            @file = AudioPlayback::File.new(@path)
            @sound = AudioPlayback::Sound.new(@file)
            @playback = AudioPlayback::Playback.new(@sound, @output, stream: MockStream.new(@output), duration: @duration)
            @data = @sound.data
            @frames = AudioPlayback::Playback::FrameSet.new(@playback).slice(AudioPlayback::Playback::METADATA.size..-1)
          end

          should "truncate to the corret length" do
            refute_nil @frames
            assert @frames.kind_of?(Array)
            refute_empty @frames
            size = [@playback.sounds.map(&:size).max, (@duration * @sample_rate).to_i].min
            assert size, @frames.length
          end

        end

        context "stereo file" do

          setup do
            @duration = 0.8
            @path = "test/media/1-stereo-#{@sample_rate}.wav"
            @file = AudioPlayback::File.new(@path)
            @sound = AudioPlayback::Sound.new(@file)
            @playback = AudioPlayback::Playback.new(@sound, @output, stream: MockStream.new(@output), duration: 0.8)
            @data = @sound.data
            @frames = AudioPlayback::Playback::FrameSet.new(@playback).slice(AudioPlayback::Playback::METADATA.size..-1)
          end

          should "truncate to the correct length" do
            refute_nil @frames
            assert @frames.kind_of?(Array)
            refute_empty @frames
            size = [@playback.sounds.map(&:size).max, (@duration * @sample_rate).to_i].min
            assert size, @frames.length
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
            @output = MockOutput.new(1, num_channels: 1)
            @playback = AudioPlayback::Playback.new(@sound, @output, stream: MockStream.new(@output))
            @data = @sound.data
            @frames = AudioPlayback::Playback::FrameSet.new(@playback).slice(AudioPlayback::Playback::METADATA.size..-1)
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
            @output = MockOutput.new(1, num_channels: 2)
            @playback = AudioPlayback::Playback.new(@sound, @output, stream: MockStream.new(@output))
            @data = @sound.data
            @frames = AudioPlayback::Playback::FrameSet.new(@playback).slice(AudioPlayback::Playback::METADATA.size..-1)
          end

          should "have one channel of valid data" do
            refute_nil @frames
            assert @frames.kind_of?(Array)
            refute_empty @frames
            assert @frames.all? { |frame_channels| frame_channels.kind_of?(AudioPlayback::Playback::Frame) }
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
            @output = MockOutput.new(1, num_channels: 2)
            @playback = AudioPlayback::Playback.new(@sound, @output, stream: MockStream.new(@output))
            @data = @sound.data
            @frames = AudioPlayback::Playback::FrameSet.new(@playback).slice(AudioPlayback::Playback::METADATA.size..-1)
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
            @output = MockOutput.new(1, num_channels: 1)
            @playback = AudioPlayback::Playback.new(@sound, @output, stream: MockStream.new(@output))
            @data = @sound.data
            @frames = AudioPlayback::Playback::FrameSet.new(@playback).slice(AudioPlayback::Playback::METADATA.size..-1)
          end

          should "have one channel of valid data" do
            refute_nil @frames
            assert @frames.kind_of?(Array)
            refute_empty @frames
            assert @frames.all? { |frame_channels| frame_channels.kind_of?(AudioPlayback::Playback::Frame) }
            assert @frames.all? { |frame_channels| frame_channels.count == @output.num_channels }
            refute @frames.any? { |frame_channels| frame_channels.count == @sound.num_channels }
            assert @frames.all? { |frame_channels| frame_channels.all? { |frame| frame.kind_of?(Float) } }
          end

        end

      end

    end

  end

end
