module AudioPlayback

  module Playback

    class Frame

      extend Forwardable

      attr_reader :frame
      def_delegators :@frame, :[], :all?, :any?, :count, :each, :flatten, :map, :size, :to_ary

      def initialize(frame)
        @frame = frame.frame if frame.kind_of?(Frame)
        @frame ||= frame
      end

      def truncate(num)
        @frame.slice!(num..-1)
      end

      # @param [<Array<Float>, Array<Array<Float>>] frame
      # @param [Fixnum] size
      # @param [Fixnum] difference
      # @param [Hash] options
      # @option options [Array<Fixnum>] :channels
      # @return [Boolean]
      def fill(size, difference, options = {})
        if (channels = options[:channels]).nil?
          @frame.fill(@frame.last, @frame.size, difference)
        else
          fill_for_channels(size, channels)
        end
        true
      end

      private

      # @param [<Array<Float>, Array<Array<Float>>] frame
      # @param [Fixnum] size
      # @param [Array<Fixnum>] channels
      # @return [Boolean]
      def fill_for_channels(size, channels)
        values = @frame.dup
        @frame.fill(0, 0, size)
        channels.each do |channel|
          value = values[channel] || values.first
          @frame[channel] = value
        end
        true
      end

    end

  end

end
