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

      attr_reader :buffer_size,
                  :channels,
                  :data,
                  :num_channels,
                  :output,
                  :sounds,
                  :stream,
                  :truncate

      def_delegators :@sounds, :audio_files
      def_delegators :@data, :reset, :size

      # @param [Array<Sound>, Sound] sounds
      # @param [Output] output
      # @param [Hash] options
      # @option options [Fixnum] :buffer_size
      # @option options [Array<Fixnum>, Fixnum] :channels (or: :channel)
      # @option options [Numeric] :duration Play for given time in seconds
      # @option options [Numeric] :end_position Stop at given time position in seconds (will use :duration if both are included)
      # @option options [IO] :logger
      # @option options [Numeric] :seek Start at given time position in seconds
      # @option options [Stream] :stream
      def initialize(sounds, output, options = {})
        @sounds = Array(sounds)
        @buffer_size = options[:buffer_size] || DEFAULT[:buffer_size]
        @output = output
        @stream = options[:stream] || Device::Stream.new(@output, options)
        populate(options)
        report(options[:logger]) if options[:logger]
      end

      # Sample rate of the playback sound
      # @return [Fixnum]
      def sample_rate
        @sounds.last.sample_rate
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

      # Should playback be truncated?
      #  eg :start 3 seconds, :duration 1 second
      # @return [Boolean]
      def truncate?
        !@truncate.nil? && !@truncate.values.empty?
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
        frames = size * @num_channels
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

      # Populate the truncation parameters. Converts the seconds based arguments to number
      # of frames
      # @param [Hash] options
      # @option options [Numeric] :duration Play for given time in seconds
      # @option options [Numeric] :end_position Stop at given time position in seconds (will use :duration if both are included)
      # @option options [Numeric] :seek Start at given time position in seconds
      # @return [Hash]
      def populate_truncation(options = {})
        @truncate = {}
        duration = options[:duration]
        if options[:seek].nil?
          duration ||= options[:end_position]
        else
          seek = options[:seek]
          unless options[:end_position].nil?
            duration ||= options[:end_position] - options[:seek]
          end
        end
        unless seek.nil?
          @truncate[:seek] = number_of_seconds_to_number_of_frames(seek)
        end
        unless duration.nil?
          @truncate[:duration] = number_of_seconds_to_number_of_frames(duration)
        end
        @truncate
      end

      # Convert number of seconds to number of sample frames given the sample rate
      # @param [Numeric] num_seconds
      # @return [Fixnum]
      def number_of_seconds_to_number_of_frames(num_seconds)
        (num_seconds * sample_rate).to_i
      end

      def truncate_valid?(options)
        options[:end_position].nil? || options[:seek].nil? ||
          options[:end_position] > options[:seek]
      end

      # Has truncation been requested in the constructor options?
      # @param [Hash] options
      # @option options [Numeric] :duration Play for given time in seconds
      # @option options [Numeric] :end_position Stop at given time position in seconds (will use :duration if both are included)
      # @option options [Numeric] :seek Start at given time position in seconds
      # @return [Boolean]
      def truncate_requested?(options)
        !options[:seek].nil? || !options[:duration].nil? || !options[:end_position].nil?
      end

      # Populate the playback action
      # @param [Hash] options
      # @option options [Fixnum, Array<Fixnum>] :channels (or: :channel)
      # @return [Playback::Action]
      def populate(options = {})
        populate_channels(options)
        if truncate_requested?(options)
          if !truncate_valid?(options)
            raise "Seek and end_position options are not valid"
          else
            populate_truncation(options)
          end
        end
        @data = StreamData.new(self)
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
