module AudioPlayback

  module Playback

    class FrameSet

      extend Forwardable

      def_delegators :@data, :flatten, :slice, :to_ary, :unshift

      def initialize(playback)
        populate(playback)
      end

      private

      def populate(playback)
        data = playback.sound.data.dup
        data = ensure_array_frames(data)
        data = to_frame_objects(data)

        @data = if channels_match?(playback)
          data
        else
          build_channels(playback, data)
        end
      end

      def channels_match?(playback)
        playback.sound.num_channels == playback.num_channels && playback.channels.nil?
      end

      def build_channels(playback, data)
        ensure_num_channels(data, playback.num_channels)

        if playback.channels_requested?
          ensure_requested_channels(data, playback)
        else
          ensure_output_channels(data, playback)
        end
        data
      end

      def ensure_requested_channels(data, playback)
        ensure_num_channels(data, playback.output.num_channels, :channels => playback.channels)
      end

      def ensure_output_channels(data, playback)
        if playback.num_channels != playback.output.num_channels
          ensure_num_channels(data, playback.output.num_channels)
        end
      end

      def ensure_num_channels(data, num, options = {})
        data.each do |frame|
          difference = num - frame.size
          if difference > 0
            frame.fill(num, difference, :channels => options[:channels])
          else
            frame.truncate(num)
          end
        end
      end

      def ensure_array_frames(data)
        if data.sample.kind_of?(Array)
          data
        else
          data.map { |frame| Array(frame) }
        end
      end

      def to_frame_objects(data)
        data.map { |frame| Frame.new(frame) }
      end

    end
    
  end

end
