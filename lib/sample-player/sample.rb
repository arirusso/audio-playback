module SamplePlayer

  class Sample

    extend Forwardable

    attr_reader :audio_file, :data, :size
    def_delegators :@audio_file, :num_channels, :sample_rate

    def self.load(filename)
      file = AudioFile.new(filename)
      new(file)
    end

    def initialize(audio_file, options = {})
      @audio_file = audio_file
      populate
    end

    private

    def populate
      @data = @audio_file.read
      @size = data.size
    end

  end

end
