module AudioPlayback

  class Playback

    extend Forwardable

    attr_reader :buffer_size, :data, :sound, :stream
    def_delegators :@sound, :audio_file, :num_channels, :sample_rate, :size

    DEFAULT = {
      :buffer_size => 2**12
    }.freeze

    METADATA = [:size, :num_channels, :counter, :eof].freeze

    def self.play(sound, output, options = {})
      playback = new(sound, output, options)
      playback.start
    end

    def initialize(sound, output, options = {})
      @sound = sound
      @buffer_size = options[:buffer_size] || DEFAULT[:buffer_size]
      @output = output
      @stream = options[:stream] || Stream.new(@output)
      populate
      report
    end

    def start
      @stream.play(self)
      self
    end

    def block
      @stream.block
    end

    def report
      puts "Playing #{@sound.audio_file.path} with buffer size #{@buffer_size}"
    end

    # Bytes
    def data_size
      frames = (@sound.size * @output.num_channels) + METADATA.count
      frames * FFI::TYPE_FLOAT32.size
    end

    def frames
      @frames ||= ensure_structure(@sound.data.dup)
    end

    private

    def pointer(data)
      pointer = LibC.malloc(data_size)
      pointer.write_array_of_float(data)
      pointer
    end

    def ensure_structure(data)
      data = ensure_array_frames(data)
      if @sound.num_channels == @output.num_channels
        data
      else
        ensure_num_channels(data, @output.num_channels)
      end
    end

    def ensure_num_channels(data, num)
      data.each do |frame|
        difference = num - frame.size
        if difference > 0
          frame.fill(frame.last, frame.size, difference)
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
      data.unshift(0.0) # 3. eof
      data.unshift(0.0) # 2. counter
      data.unshift(@output.num_channels.to_f) # 1. num_channels
      data.unshift(@sound.size.to_f) # 0. sample size
      data
    end

    def populate
      data = frames
      add_metadata(data)
      @data = pointer(data.flatten)
    end
  end

end
