module SamplePlayer

  class Sample

    extend Forwardable

    attr_reader :audio_file, :data, :frame_size, :size
    def_delegators :@audio_file, :num_channels, :sample_rate

    DEFAULT = {
      :frame_size => 2**12
    }.freeze

    def self.load(filename)
      file = AudioFile.new(filename)
      new(file)
    end

    def initialize(audio_file, options = {})
      @audio_file = audio_file
      @frame_size = options[:frame_size] || DEFAULT[:frame_size] #File.size(filename)
      populate
    end

    def size_in_bytes
      @size * FFI::TYPE_FLOAT32.size
    end

    private

    def pointer(data)
      pointer = LibC.malloc(size_in_bytes + 1)
      pointer.write_array_of_float(data)
      pointer
    end

    def populate
      data = @audio_file.read(@frame_size)
      @size = data.size
      data.unshift(@size)
      @data = pointer(data)
    end
  end

end
