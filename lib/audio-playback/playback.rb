require "audio-playback/playback/frame"
require "audio-playback/playback/frame_set"
require "audio-playback/playback/stream_data"

module AudioPlayback

  module Playback

    DEFAULT = {
      :buffer_size => 2**12
    }.freeze

    FRAME_SIZE = FFI::TYPE_FLOAT32.size

    METADATA = [:size, :num_channels, :pointer, :is_eof].freeze

    # Action of playing back an audio file
    class Action

      extend Forwardable

      attr_reader :buffer_size, :channels, :data, :output, :num_channels, :sound, :stream
      def_delegators :@sound, :audio_file, :sample_rate, :size

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

    end

    def self.new(*args)
      Action.new(*args)
    end

    # @param [Sound] sound
    # @param [Output] output
    # @param [Hash] options
    # @option options [Fixnum] :buffer_size
    # @option options [Array<Fixnum>, Fixnum] :channels (or: :channel)
    # @option options [IO] :logger
    # @option options [Stream] :stream
    # @return [Playback]
    def self.play(sound, output, options = {})
      playback = Action.new(sound, output, options)
      playback.start
    end

  end

end
