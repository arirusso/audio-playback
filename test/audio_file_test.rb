require "helper"

class SamplePlayer::AudioFileTest < Minitest::Test

  context "AudioFile" do

    context ".new" do

      context "mono" do

        setup do
          @path = "test/media/mono.wav"
          @file = SamplePlayer::AudioFile.new(@path)
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
          @path = "test/media/stereo.wav"
          @file = SamplePlayer::AudioFile.new(@path)
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
          assert_equal 48000, @file.sample_rate.to_i
          assert_equal @path, @file.path
          assert_equal File.size(@path), @file.size
        end

      end

    end

  end

end
