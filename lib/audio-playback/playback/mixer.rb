module AudioPlayback

  module Playback

    # Mix sound data
    module Mixer

      # Mix multiple sounds at equal amplitude
      # @param [Array<Array<Array<Fixnum>>>] datas
      # @return [Array<Array<Fixnum>>]
      def self.mix(datas)
        length = datas.map(&:size).max
        depth = datas.count

        (0..length-1).to_a.map do |i|
          frames = datas.map { |sound_data| sound_data[i] }
          totals = frames.compact.transpose.map { |x| x && x.reduce(:+) || 0 }
          totals.map { |frame| frame / depth }
        end
      end

    end

  end

end
