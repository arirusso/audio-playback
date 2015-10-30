module AudioPlayback

  module Playback

    # Mix sound data
    class Mixer

      # Mix multiple sounds at equal amplitude
      # @param [Array<Array<Array<Fixnum>>>] sounds_data
      # @return [Array<Array<Fixnum>>]
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

      # Populate the mixer metadata
      # @return [Mixer]
      def populate
        @length = @data.map(&:size).max
        @depth = @data.count
        self
      end

      # Get all of the data frames for the given index
      # For example for index 3, two two channel sounds, frames(3) might give you [[1, 3], [2, 3]]
      # @param [Fixnum] index
      # @return [Array<Array<Fixnum>>]
      def frames(index)
        @data.map { |sound_data| sound_data[index] }
      end

      # Mix the frame with the given index
      # whereas frames(3) might give you [[1, 3], [2, 3]]
      # mix_frame(3) might give you [1.5, 3]
      # @param [Fixnum] index
      # @return [Array<Fixnum>]
      def mix_frame(index)
        totals = frames(index).compact.transpose.map { |x| x && x.reduce(:+) || 0 }
        totals.map { |frame| frame / @depth }
      end

    end

  end

end
