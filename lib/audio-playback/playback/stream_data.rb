module AudioPlayback

  module Playback

    # Playback data for the Device::Stream
    class StreamData

      extend Forwardable

      def_delegators :@data, :length, :size

      # A C pointer version of the audio data
      # @param [Playback::Action] playback
      # @return [FFI::Pointer]
      def self.to_pointer(playback)
        stream_data = new(playback)
        stream_data.to_pointer
      end

      # @param [Playback::Action] playback
      def initialize(playback)
        @playback = playback
        populate
      end

      # Reset the stream metadata
      # @param [Boolean]
      def reset
        indexes = [
          Playback::METADATA.index(:pointer),
          Playback::METADATA.index(:is_eof)
        ]
        indexes.each { |index| @data[index] = 0.0 }
        true
      end

      # A C pointer version of the audio data
      # @return [FFI::Pointer]
      def to_pointer
        @pointer ||= FFI::LibC.malloc(@playback.data_size)
        @pointer.write_array_of_float(@data.flatten)
        @pointer
      end

      private

      # Populate the playback stream data
      # @return [FrameSet]
      def populate
        @data = FrameSet.new(@playback)
        add_metadata
        @data
      end

      # Add playback metadata to the stream data
      # @return [FrameSet]
      def add_metadata
        size = @data.size
        if @playback.truncate?
          end_frame = @playback.truncate[:end_frame]
          start_frame = @playback.truncate[:start_frame]
        end
        @data.unshift(0.0) # 5. is_eof
        @data.unshift(start_frame || 0.0) # 4. counter
        @data.unshift(end_frame || size) # 3. end frame
        @data.unshift(start_frame || 0.0) # 2. start frame
        @data.unshift(@playback.output.num_channels.to_f) # 1. num_channels
        @data.unshift(size.to_f) # 0. frame set size (without metadata)
        @data
      end

    end

  end

end
