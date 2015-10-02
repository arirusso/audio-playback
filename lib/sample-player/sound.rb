module SamplePlayer

  class Sound

    extend Forwardable

    attr_reader :audio_file, :data, :size
    def_delegators :@audio_file, :num_channels, :sample_rate

    def self.load(filename)
      file = SamplePlayer::File.new(filename)
      new(file)
    end

    def initialize(audio_file, options = {})
      @audio_file = audio_file
      populate
      report
    end

    def report
      puts "Sound report for #{@audio_file.path}"
      puts "Sample rate: #{@audio_file.sample_rate}"
      puts "Channels: #{@audio_file.num_channels}"
      puts "File size: #{@audio_file.size}"
    end

    private

    def populate
      @data = @audio_file.read
      @size = data.size
    end

  end

end
