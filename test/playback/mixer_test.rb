require "helper"

class AudioPlayback::Playback::MixerTest < Minitest::Test

  context "Mixer" do

    context ".mix" do

      setup do
        @sound1 = [[1,2],[3,4],[5, 6]]
        @sound2 = [[7,8],[9, 10]]
        @sound = [@sound1, @sound2]
      end

      should "mix channels" do
        @result = AudioPlayback::Playback::Mixer.mix(@sound)
        refute_nil @result
        assert_equal [[4, 5], [6, 7], [2, 3]], @result
      end

    end

  end

end
