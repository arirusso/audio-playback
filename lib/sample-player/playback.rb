module SamplePlayer

  class Playback

    extend Forwardable

    attr_reader :frame_size, :data, :sample
    def_delegators :@sample, :audio_file, :num_channels, :sample_rate, :size

    DEFAULT = {
      :frame_size => 2**12
    }.freeze

    NUM_METADATA_BYTES = 3

    def initialize(sample, options = {})
      @sample = sample
      @frame_size = options[:frame_size] || DEFAULT[:frame_size] #File.size(filename)
      populate
      report
    end

    def report
      puts "Playing #{@sample.audio_file.path} with frame size #{@frame_size}"
    end

    def size_in_bytes
      @sample.size * FFI::TYPE_FLOAT32.size
    end

    private

    def pointer(data)
      pointer = LibC.malloc(size_in_bytes + NUM_METADATA_BYTES)
      pointer.write_array_of_float(data)
      pointer
    end

    def populate
      data = @sample.data
      data.unshift(@sample.size)
      data.unshift(0.0) # counter
      data.unshift(0.0) # eof
      @data = pointer(data)
    end
  end

end
