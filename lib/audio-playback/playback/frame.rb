module AudioPlayback

  module Playback

    # A single frame of audio data in the FrameSet
    class Frame

      extend Forwardable

      attr_reader :frame
      def_delegators :@frame, :[], :all?, :any?, :count, :each, :flatten, :map, :size, :to_ary

      # @param [Array<Float>, Frame] frame
      def initialize(frame)
        @frame = frame.frame if frame.kind_of?(Frame)
        @frame ||= frame
      end

      # Truncate the frame to the given size
      # @param [Fixnum] num
      # @return [Frame]
      def truncate(num)
        @frame.slice!(num..-1)
        self
      end

      # Fill up the given number of channels at the end of the frame with duplicate data from the last
      #   existing channel
      # @param [Fixnum] num
      # @param [Hash] options
      # @option options [Array<Fixnum>] :channels (required if :num_channels is provided)
      # @option options [Fixnum] :num_channels (required if :channels is provided)
      # @return [Boolean]
      def fill(num, options = {})
        if (channels = options[:channels]).nil?
          @frame.fill(@frame.last, @frame.size, num)
        else
          fill_for_channels(options[:num_channels], channels)
        end
        true
      end

      private

      # Zero out the given number of channels in the frame starting with the given index
      # @param [Fixnum] index
      # @param [Fixnum] num_channels
      # @return [Frame]
      def silence_channels(index, num_channels)
        @frame.fill(0, index, num_channels)
        self
      end

      # Fill the entire frame for the given channels
      # @param [Fixnum] num_channels
      # @param [Array<Fixnum>] channels
      # @return [Boolean]
      def fill_for_channels(num_channels, channels)
        values = @frame.dup
        silence_channels(0, num_channels)
        channels.each do |channel|
          value = values[channel] || values.first
          @frame[channel] = value
        end
        true
      end

    end

  end

end
