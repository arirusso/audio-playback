module AudioPlayback

  class Playback

    extend Forwardable

    attr_reader :buffer_size, :data, :num_channels, :sound, :stream
    def_delegators :@sound, :audio_file, :sample_rate, :size

    DEFAULT = {
      :buffer_size => 2**12
    }.freeze

    FRAME_SIZE = FFI::TYPE_FLOAT32.size

    METADATA = [:size, :num_channels, :pointer, :is_eof].freeze

    def self.play(sound, output, options = {})
      playback = new(sound, output, options)
      playback.start
    end

    def initialize(sound, output, options = {})
      @sound = sound
      @buffer_size = options[:buffer_size] || DEFAULT[:buffer_size]
      @output = output
      @stream = options[:stream] || Stream.new(@output, options)
      populate(options)
      report(options[:logger]) if options[:logger]
    end

    def start
      @stream.play(self)
      self
    end

    def block
      @stream.block
    end

    def report(logger)
      logger.puts("Playback report for #{@sound.audio_file.path}")
      logger.puts("  Number of channels: #{@num_channels}")
      logger.puts("  Direct audio to channels #{@channels.to_s}") unless @channels.nil?
      logger.puts("  Buffer size: #{@buffer_size}")
      logger.puts("  Latency: #{@output.latency}")
      true
    end

    # Bytes
    def data_size
      frames = (@sound.size * @num_channels) + METADATA.count
      frames * FRAME_SIZE.size
    end

    def frames
      @frames ||= ensure_structure(@sound.data.dup)
    end

    private

    def pointer(data)
      pointer = FFI::LibC.malloc(data_size)
      pointer.write_array_of_float(data)
      pointer
    end

    def ensure_structure(data)
      data = ensure_array_frames(data)
      if @sound.num_channels == @num_channels && @channels.nil?
        data
      else
        ensure_num_channels(data, @num_channels)
        if @channels.nil?
          if @num_channels != @output.num_channels
            ensure_num_channels(data, @output.num_channels)
          end
        else
          ensure_num_channels(data, @output.num_channels, :channels => @channels)
        end
        data
      end
    end

    def fill_frame_for_channels(frame, size, channels)
      values = frame.dup
      frame.fill(0, 0, size)
      channels.each do |channel|
        value = values[channel] || values.first
        frame[channel] = value
      end
    end

    def fill_frame(frame, size, difference, options = {})
      if (channels = options[:channels]).nil?
        frame.fill(frame.last, frame.size, difference)
      else
        fill_frame_for_channels(frame, size, channels)
      end
    end

    def ensure_num_channels(data, num, options = {})
      data.each do |frame|
        difference = num - frame.size
        if difference > 0
          fill_frame(frame, num, difference, :channels => options[:channels])
        else
          frame.slice!(num..-1)
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

    def add_metadata(data)
      data.unshift(0.0) # 3. is_eof
      data.unshift(0.0) # 2. counter
      data.unshift(@output.num_channels.to_f) # 1. num_channels
      data.unshift(@sound.size.to_f) # 0. sample size
      data
    end

    def validate_requested_channels(channels)
      if channels.count > @output.num_channels
        raise "Only #{@output.num_channels} channels available on #{@output.name} output"
        false
      end
      true
    end

    def populate_requested_channels(options = {})
      requested_channels = if options[:channels].kind_of?(Array)
        options[:channels].map(&:to_i).uniq
      else
        options[:channels].to_i
      end
      if validate_requested_channels(requested_channels)
        @num_channels = requested_channels.count
        @channels = requested_channels
      end
    end

    def populate_channels(options = {})
      if options[:channels].nil?
        @num_channels = @output.num_channels
      else
        populate_requested_channels(options)
      end
    end

    def populate(options = {})
      populate_channels(options)
      data = frames
      add_metadata(data)
      @data = pointer(data.flatten)
    end
  end

end
