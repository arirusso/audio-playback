require "helper"

class AudioPlayback::FileTest < Minitest::Test

  context "AudioFile" do

    context ".new" do

      context "mono" do

        setup do
          @path = "test/media/1-mono-44100.wav"
          @file = AudioPlayback::File.new(@path)
        end

        should "populate" do
          refute_nil @file
          refute_nil @file.num_channels
          refute_nil @file.sample_rate
          refute_nil @file.path
          refute_nil @file.size
        end

        should "have correct information" do
          assert_equal 1, @file.num_channels
          assert_equal 44100, @file.sample_rate.to_i
          assert_equal @path, @file.path
          assert_equal File.size(@path), @file.size
        end

      end

      context "stereo" do

        setup do
          @path = "test/media/1-stereo-44100.wav"
          @file_obj = File.new(@path)
          @file = AudioPlayback::File.new(@file_obj)
        end

        should "populate" do
          refute_nil @file
          refute_nil @file.num_channels
          refute_nil @file.sample_rate
          refute_nil @file.path
          refute_nil @file.size
        end

        should "have correct information" do
          assert_equal 2, @file.num_channels
          assert_equal 44100, @file.sample_rate.to_i
          assert_equal @path, @file.path
          assert_equal File.size(@path), @file.size
        end

      end

    end

    context "#read" do

      context "mono" do

        setup do
          @path = "test/media/1-mono-44100.wav"
          @file = AudioPlayback::File.new(@path)
          @data = @file.read
        end

        should "populate data" do
          refute_nil @data
          assert @data.kind_of?(Array)
          refute_empty @data
          assert @data.all? { |frame| frame.kind_of?(Float) }
          assert @data.all? { |frame| frame >= -1 }
          assert @data.all? { |frame| frame <= 1 }
        end

      end

      context "stereo" do

        setup do
          @path = "test/media/1-stereo-44100.wav"
          @file = AudioPlayback::File.new(@path)
          @data = @file.read
        end

        should "populate data" do
          refute_nil @data
          assert @data.kind_of?(Array)
          refute_empty @data
          assert @data.all? { |frame_channels| frame_channels.kind_of?(Array) }
          assert @data.all? { |frame_channels| frame_channels.all? { |frame| frame.kind_of?(Float) } }
          assert @data.all? { |frame_channels| frame_channels.all? { |frame| frame >= -1 } }
          assert @data.all? { |frame_channels| frame_channels.all? { |frame| frame <= 1 } }
        end

      end

    end

  end

end
