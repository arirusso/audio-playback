module AudioPlayback

  module Playback

    # Mix sound data
    class Mixer

      def self.mix(sounds_data)
        mixer = new(sounds_data)
        mixer.mix
      end

      # @param [Array<Array<Array<Fixnum>>>] sounds_data
      def initialize(sounds_data)
        @data = sounds_data
        populate
      end

      # Mix multiple sounds at equal amplitude
      # @return [Array<Array<Fixnum>>]
      def mix
        (0..@length-1).to_a.map { |index| mix_frame(index) }
      end

      private

      def populate
        @length = @data.map(&:size).max
        @depth = @data.count
      end

      def frames(index)
        @data.map { |sound_data| sound_data[index] }
      end

      def mix_frame(index)
        totals = frames(index).compact.transpose.map { |x| x && x.reduce(:+) || 0 }
        totals.map { |frame| frame / @depth }
      end

    end

  end

end
