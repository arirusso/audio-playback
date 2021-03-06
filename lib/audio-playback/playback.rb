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

    METADATA = [:size, :num_channels, :start_frame, :end_frame, :is_looping, :pointer, :is_eof].freeze

    class InvalidChannels < RuntimeError
    end

    class InvalidTruncation < RuntimeError
    end

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
      # @option options [Integer] :buffer_size
      # @option options [Array<Integer>, Integer] :channels (or: :channel)
      # @option options [Numeric] :duration Play for given time in seconds
      # @option options [Numeric] :end_position Stop at given time position in seconds (will use :duration if both are included)
      # @option options [Boolean] :is_looping Whether to loop audio
      # @option options [IO] :logger
      # @option options [Numeric] :seek Start at given time position in seconds
      # @option options [Stream] :stream
      def initialize(sounds, output, options = {})
        @channels = nil
        @truncate = nil
        @sounds = Array(sounds)
        @buffer_size = options[:buffer_size] || DEFAULT[:buffer_size]
        @output = output
        @stream = options[:stream] || Device::Stream.new(@output, options)
        populate(options)
        report(options[:logger]) if options[:logger]
      end

      # Sample rate of the playback sound
      # @return [Integer]
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
        logger.send(:puts, "Playback report for #{paths}")
        logger.send(:puts, "  Number of channels: #{@num_channels}")
        logger.send(:puts, "  Direct audio to channels #{@channels.to_s}") unless @channels.nil?
        logger.send(:puts, "  Buffer size: #{@buffer_size}")
        logger.send(:puts, "  Latency: #{@output.latency}")
        true
      end

      # Total size of the playback's sound frames in bytes
      # @return [Integer]
      def data_size
        frames = size * @num_channels
        frames * FRAME_SIZE.size
      end

      # Has a different channel configuration than the default been requested?
      # @return [Boolean]
      def channels_requested?
        !@channels.nil?
      end

      # Is audio looping ?
      # @return [Boolean]
      def looping?
        @is_looping
      end

      private

      # Are the requested channels available in the current environment?
      # @param [Array<Integer>] channels
      # @return [Boolean]
      def validate_requested_channels(channels)
        if channels.count > @output.num_channels
          message = "Only #{@output.num_channels} channels available on #{@output.name} output"
          raise(InvalidChannels.new(message))
          false
        end
        true
      end

      # Validate and populate the variables containing information about the requested channels
      # @param [Integer, Array<Integer>] request Channel(s)
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
      # @option options [Integer, Array<Integer>] :channels (or: :channel)
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

      # Populate the truncation parameters. Converts the seconds based Position arguments
      # to number of frames
      # @param [Position, nil] seek Start at given time position in seconds
      # @param [Position, nil] duration Play for given time in seconds
      # @param [Position, nil] end_position Stop at given time position in seconds (will use duration arg if both are included)
      # @return [Hash]
      def populate_truncation(seek, duration, end_position)
        @truncate = {}
        end_position = if duration.nil?
          end_position
        elsif seek.nil?
          duration || end_position
        else
          duration + seek || end_position
        end
        unless seek.nil?
          @truncate[:start_frame] = number_of_seconds_to_number_of_frames(seek)
        end
        unless end_position.nil?
          @truncate[:end_frame] = number_of_seconds_to_number_of_frames(end_position)
        end
        @truncate
      end

      # Convert number of seconds to number of sample frames given the sample rate
      # @param [Numeric] num_seconds
      # @return [Integer]
      def number_of_seconds_to_number_of_frames(num_seconds)
        (num_seconds * sample_rate).to_i
      end

      # Are the options for truncation valid? eg is the :end_position option after the
      # :seek option?
      # @param [Hash] options
      # @option options [Numeric] :duration Play for given time in seconds
      # @option options [Numeric] :end_position Stop at given time position in seconds (will use :duration if both are included)
      # @option options [Numeric] :seek Start at given time position in seconds
      # @return [Boolean]
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

      # Populate Position objects using the the truncation parameters.
      # @param [Hash] options
      # @option options [Numeric] :duration Play for given time in seconds
      # @option options [Numeric] :end_position Stop at given time position in seconds (will use :duration if both are included)
      # @option options [Numeric] :seek Start at given time position in seconds
      # @return [Array<Position>]
      def truncate_options_as_positions(options = {})
        seek = Position.new(options[:seek]) unless options[:seek].nil?
        duration = Position.new(options[:duration]) unless options[:duration].nil?
        end_position = Position.new(options[:end_position]) unless options[:end_position].nil?
        [seek, duration, end_position]
      end

      # Populate the playback action
      # @param [Hash] options
      # @option options [Integer, Array<Integer>] :channels (or: :channel)
      # @option options [Numeric] :duration Play for given time in seconds
      # @option options [Numeric] :end_position Stop at given time position in seconds (will use :duration if both are included)
      # @option options [Boolean] :is_looping Whether to loop audio
      # @option options [Numeric] :seek Start at given time position in seconds
      # @return [Playback::Action]
      def populate(options = {})
        populate_channels(options)
        if truncate_requested?(options)
          if truncate_valid?(options)
            seek, duration, end_position = *truncate_options_as_positions(options)
            populate_truncation(seek, duration, end_position)
          else
            message = "Truncation options are not valid"
            raise(InvalidTruncation.new(message))
          end
        end
        @is_looping = !!options[:is_looping]
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
    # @option options [Integer] :buffer_size
    # @option options [Array<Integer>, Integer] :channels (or: :channel)
    # @option options [IO] :logger
    # @option options [Stream] :stream
    # @return [Playback]
    def self.play(sound, output, options = {})
      playback = Action.new(sound, output, options)
      playback.start
    end

  end

end
