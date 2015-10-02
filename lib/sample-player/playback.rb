module SamplePlayer

  class Playback

    extend Forwardable

    attr_reader :frame_size, :data, :sample
    def_delegators :@sample, :audio_file, :num_channels, :sample_rate, :size

    DEFAULT = {
      :frame_size => 2**12
    }.freeze

    METADATA = [:size, :num_channels, :counter, :eof].freeze

    def initialize(sample, options = {})
      @sample = sample
      @frame_size = options[:frame_size] || DEFAULT[:frame_size] #File.size(filename)
      populate
      report
    end

    def report
      puts "Playing #{@sample.audio_file.path} with buffer size #{@frame_size}"
    end

    # Bytes
    def data_size
      ((@sample.size * @sample.num_channels) + METADATA.count) * FFI::TYPE_FLOAT32.size
    end

    private

    def pointer(data)
      pointer = LibC.malloc(data_size)
      pointer.write_array_of_float(data)
      pointer
    end

    def populate
      data = @sample.data
      data.unshift(0.0) # 3. eof
      data.unshift(0.0) # 2. counter
      data.unshift(@sample.num_channels.to_f) # 1. num_channels
      data.unshift(@sample.size.to_f) # 0. sample size
      @data = pointer(data.flatten)
    end
  end

end
