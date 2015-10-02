module AudioPlayback

  class Playback

    extend Forwardable

    attr_reader :buffer_size, :data, :sound
    def_delegators :@sound, :audio_file, :num_channels, :sample_rate, :size

    DEFAULT = {
      :buffer_size => 2**12
    }.freeze

    METADATA = [:size, :num_channels, :counter, :eof].freeze

    def initialize(sound, options = {})
      @sound = sound
      @buffer_size = options[:buffer_size] || DEFAULT[:buffer_size]
      populate
      report
    end

    def report
      puts "Playing #{@sound.audio_file.path} with buffer size #{@buffer_size}"
    end

    # Bytes
    def data_size
      frames = (@sound.size * @sound.num_channels) + METADATA.count
      frames * FFI::TYPE_FLOAT32.size
    end

    private

    def pointer(data)
      pointer = LibC.malloc(data_size)
      pointer.write_array_of_float(data)
      pointer
    end

    def populate
      data = @sound.data
      data.unshift(0.0) # 3. eof
      data.unshift(0.0) # 2. counter
      data.unshift(@sound.num_channels.to_f) # 1. num_channels
      data.unshift(@sound.size.to_f) # 0. sample size
      @data = pointer(data.flatten)
    end
  end

end
