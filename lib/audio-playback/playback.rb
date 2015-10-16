module AudioPlayback

  # Action of playing back an audio file
  class Playback

    extend Forwardable

    attr_reader :buffer_size, :channels, :data, :output, :num_channels, :sound, :stream
    def_delegators :@sound, :audio_file, :sample_rate, :size

    DEFAULT = {
      :buffer_size => 2**12
    }.freeze

    FRAME_SIZE = FFI::TYPE_FLOAT32.size

    METADATA = [:size, :num_channels, :pointer, :is_eof].freeze

    # @param [Sound] sound
    # @param [Output] output
    # @param [Hash] options
    # @option options [Fixnum] :buffer_size
    # @option options [Array<Fixnum>, Fixnum] :channels (or: :channel)
    # @option options [IO] :logger
    # @option options [Stream] :stream
    # @return [Playback]
    def self.play(sound, output, options = {})
      playback = new(sound, output, options)
      playback.start
    end

    # @param [Sound] sound
    # @param [Output] output
    # @param [Hash] options
    # @option options [Fixnum] :buffer_size
    # @option options [Array<Fixnum>, Fixnum] :channels (or: :channel)
    # @option options [IO] :logger
    # @option options [Stream] :stream
    def initialize(sound, output, options = {})
      @sound = sound
      @buffer_size = options[:buffer_size] || DEFAULT[:buffer_size]
      @output = output
      @stream = options[:stream] || Stream.new(@output, options)
      populate(options)
      report(options[:logger]) if options[:logger]
    end

    # Start playback
    # @return [Playback]
    def start
      @stream.play(self)
      self
    end

    # Block process until playback finishes
    # @return [Stream]
    def block
      @stream.block
    end

    # Log a report about playback
    # @param [IO] logger
    # @return [Boolean]
    def report(logger)
      logger.puts("Playback report for #{@sound.audio_file.path}")
      logger.puts("  Number of channels: #{@num_channels}")
      logger.puts("  Direct audio to channels #{@channels.to_s}") unless @channels.nil?
      logger.puts("  Buffer size: #{@buffer_size}")
      logger.puts("  Latency: #{@output.latency}")
      true
    end

    # Total size of the playback's sound frames in bytes
    # @return [Fixnum]
    def data_size
      frames = (@sound.size * @num_channels) + METADATA.count
      frames * FRAME_SIZE.size
    end

    def channels_requested?
      !@channels.nil?
    end

    private

    def validate_requested_channels(channels)
      if channels.count > @output.num_channels
        raise "Only #{@output.num_channels} channels available on #{@output.name} output"
        false
      end
      true
    end

    def populate_requested_channels(request)
      request = Array(request)
      requested_channels = request.map(&:to_i).uniq
      if validate_requested_channels(requested_channels)
        @num_channels = requested_channels.count
        @channels = requested_channels
      end
    end

    def populate_channels(options = {})
      request = options[:channels] || options[:channel]
      if request.nil?
        @num_channels = @output.num_channels
      else
        populate_requested_channels(request)
      end
    end

    def populate(options = {})
      populate_channels(options)
      @data = StreamData.to_pointer(self)
    end

    class StreamData

      # A C pointer version of the audio data
      def self.to_pointer(playback)
        stream_data = new(playback)
        stream_data.to_pointer
      end

      def initialize(playback)
        @playback = playback
        populate
      end

      # A C pointer version of the audio data
      def to_pointer
        pointer = FFI::LibC.malloc(@playback.data_size)
        pointer.write_array_of_float(@data.flatten)
        pointer
      end

      private

      def populate
        @data = FrameSet.new(@playback)
        add_metadata
        @data
      end

      def add_metadata
        @data.unshift(0.0) # 3. is_eof
        @data.unshift(0.0) # 2. counter
        @data.unshift(@playback.output.num_channels.to_f) # 1. num_channels
        @data.unshift(@playback.sound.size.to_f) # 0. sample size
        @data
      end

    end

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
