require "audio-playback/playback/frame"
require "audio-playback/playback/frame_set"
require "audio-playback/playback/mixer"
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

      attr_reader :buffer_size, :channels, :data, :output, :num_channels, :sounds, :stream
      def_delegators :@sounds, :audio_files

      # @param [Array<Sound>, Sound] sounds
      # @param [Output] output
      # @param [Hash] options
      # @option options [Fixnum] :buffer_size
      # @option options [Array<Fixnum>, Fixnum] :channels (or: :channel)
      # @option options [IO] :logger
      # @option options [Stream] :stream
      def initialize(sounds, output, options = {})
        @sounds = Array(sounds)
        @buffer_size = options[:buffer_size] || DEFAULT[:buffer_size]
        @output = output
        @stream = options[:stream] || Device::Stream.new(@output, options)
        populate(options)
        report(options[:logger]) if options[:logger]
      end

      def sample_rate
        @sounds.last.sample_rate
      end

      def size
        @sounds.map(&:size).max
      end

      # Start playback
      # @return [Playback]
      def start
        @stream.play(self)
        self
      end
      alias_method :play, :start

      # Block process until playback finishes
      # @return [Stream]
      def block
        @stream.block
      end

      # Log a report about playback
      # @param [IO] logger
      # @return [Boolean]
      def report(logger)
        paths = @sounds.map(&:audio_file).map(&:path)
        logger.puts("Playback report for #{paths}")
        logger.puts("  Number of channels: #{@num_channels}")
        logger.puts("  Direct audio to channels #{@channels.to_s}") unless @channels.nil?
        logger.puts("  Buffer size: #{@buffer_size}")
        logger.puts("  Latency: #{@output.latency}")
        true
      end

      # Total size of the playback's sound frames in bytes
      # @return [Fixnum]
      def data_size
        frames = (size * @num_channels) + METADATA.count
        frames * FRAME_SIZE.size
      end

      # Has a different channel configuration than the default been requested?
      # @return [Boolean]
      def channels_requested?
        !@channels.nil?
      end

      private

      # Are the requested channels available in the current environment?
      # @param [Array<Fixnum>] channels
      # @return [Boolean]
      def validate_requested_channels(channels)
        if channels.count > @output.num_channels
          raise "Only #{@output.num_channels} channels available on #{@output.name} output"
          false
        end
        true
      end

      # Validate and populate the variables containing information about the requested channels
      # @param [Fixnum, Array<Fixnum>] request Channel(s)
      # @return [Boolean]
      def populate_requested_channels(request)
        request = Array(request)
        requested_channels = request.map(&:to_i).uniq
        if validate_requested_channels(requested_channels)
          @num_channels = requested_channels.count
          @channels = requested_channels
          true
        else
          false
        end
      end

      # Populate the playback channels
      # @param [Hash] options
      # @option options [Fixnum, Array<Fixnum>] :channels (or: :channel)
      # @return [Boolean]
      def populate_channels(options = {})
        request = options[:channels] || options[:channel]
        if request.nil?
          @num_channels = @output.num_channels
          true
        else
          populate_requested_channels(request)
        end
      end

      # Populate the playback action
      # @param [Hash] options
      # @option options [Fixnum, Array<Fixnum>] :channels (or: :channel)
      # @return [Playback::Action]
      def populate(options = {})
        populate_channels(options)
        @data = StreamData.to_pointer(self)
        self
      end

    end

    # Shortcut to Action.new
    # @return [Playback::Action]
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
