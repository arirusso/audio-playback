module AudioPlayback

  module Playback

    # Container for playback data
    class FrameSet

      extend Forwardable

      def_delegators :@data, :flatten, :slice, :to_ary, :unshift

      # @param [Playback::Action] playback
      def initialize(playback)
        populate(playback)
      end

      private

      # Populate the Container
      # @param [Playback::Action] playback
      # @return [Array<Array<Float>>]
      def populate(playback)
        data = playback.sound.data.dup
        data = ensure_array_frames(data)
        data = to_frame_objects(data)

        @data = if channels_match?(playback)
          data
        else
          build_channels(data, playback)
        end
      end

      # Does the channel structure of the playback action match the channel structure of the sound?
      # @param [Playback::Action] playback
      # @return [Boolean]
      def channels_match?(playback)
        playback.sound.num_channels == playback.num_channels && playback.channels.nil?
      end

      # (Re-)build the channel structure of the frame set
      # @param [Array<Frame>] data
      # @param [Playback::Action] playback
      # @return [Array<Frame>]
      def build_channels(data, playback)
        ensure_num_channels(data, playback.num_channels)

        if playback.channels_requested?
          ensure_requested_channels(data, playback)
        else
          ensure_output_channels(data, playback)
        end
        data
      end

      # Build the channel structure of the frame set to what was requested of playback
      # @param [Array<Frame>] data
      # @param [Playback::Action] playback
      # @return [Array<Frame>]
      def ensure_requested_channels(data, playback)
        ensure_num_channels(data, playback.output.num_channels, :channels => playback.channels)
      end

      # Build the channel structure of the frameset to that of the playback output device
      # @param [Array<Frame>] data
      # @param [Playback::Action] playback
      # @return [Array<Frame>]
      def ensure_output_channels(data, playback)
        if playback.num_channels != playback.output.num_channels
          ensure_num_channels(data, playback.output.num_channels)
        end
      end

      # Ensure that the channel structure of the frameset is according to the given number of channels
      #    and to the given particular channels when provided
      # @param [Array<Frame>] data
      # @param [Fixnum] num_channels
      # @param [Hash] options
      # @option options [Array<Fixnum>] :channels
      # @return [Array<Frame>]
      def ensure_num_channels(data, num_channels, options = {})
        data.each do |frame|
          difference = num_channels - frame.size
          if difference > 0
            frame.fill(difference, :channels => options[:channels], :num_channels => num_channels)
          else
            frame.truncate(num_channels)
          end
        end
        data
      end

      # Ensure that the input data is Array<Array<Float>>. Single channel audio will be provided as
      #   Array<Float> and is converted here so that the frame set data structure can be built in a
      #   uniform way
      # @param [Array<Float>, Array<Array<Float>>] data
      # @return [Array<Array<Float>>]
      def ensure_array_frames(data)
        if data.sample.kind_of?(Array)
          data
        else
          data.map { |frame| Array(frame) }
        end
      end

      # Convert the raw sound data to Frame objects
      # @param [Array<Array<Float>>] data
      # @return [Array<Frame>]
      def to_frame_objects(data)
        data.map { |frame| Frame.new(frame) }
      end

    end

  end

end
