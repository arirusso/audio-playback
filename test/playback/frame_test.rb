require "helper"

class AudioPlayback::Playback::FrameTest < Minitest::Test

  context "Frame" do

    setup do
      @frame = AudioPlayback::Playback::Frame.new([1, 2, 4])
      assert_equal 3, @frame.size
    end

    context "#truncate" do

      should "truncate the frame to the given size" do
        @frame.truncate(1)
        assert_equal 1, @frame.size
      end

    end

    context "#fill" do

      context "with :num_channels option" do

        should "add n elements to the frame" do
          @frame.fill(3, :num_channels => 3, :channels => [1,2,3])
          assert_equal 4, @frame.size
          assert_equal 0, @frame[0]
        end

      end

      context "with no options" do

        should "add n elements to the frame" do
          @frame.fill(4)
          assert_equal 7, @frame.size
        end

      end

    end

  end

end
