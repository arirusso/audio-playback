module AudioPlayback

  class Sound

    extend Forwardable

    attr_reader :audio_file, :data, :size
    def_delegators :@audio_file, :num_channels, :sample_rate

    def self.load(filename, options = {})
      file = AudioPlayback::File.new(filename)
      new(file, options)
    end

    def initialize(audio_file, options = {})
      @audio_file = audio_file
      populate(options)
      report(options[:verbose]) if options[:verbose]
    end

    def report(out)
      out.puts("Sound report for #{@audio_file.path}")
      out.puts("Sample rate: #{@audio_file.sample_rate}")
      out.puts("Channels: #{@audio_file.num_channels}")
      out.puts("File size: #{@audio_file.size}")
    end

    private

    def populate(options = {})
      @data = @audio_file.read(options)
      @size = data.size
    end

  end

end
