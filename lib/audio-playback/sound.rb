module AudioPlayback

  class Sound

    extend Forwardable

    attr_reader :audio_file, :data, :size
    def_delegators :@audio_file, :num_channels, :sample_rate

    # Load a sound from the given file path
    # @param [::File, String] file_or_path
    # @param [Hash] options
    # @option options [IO] logger
    # @return [Sound]
    def self.load(file_or_path, options = {})
      file = AudioPlayback::File.new(file_or_path)
      new(file, options)
    end

    # @param [AudioPlayback::File] audio_file
    # @param [Hash] options
    # @option options [IO] logger
    def initialize(audio_file, options = {})
      @audio_file = audio_file
      populate(options)
      report(options[:logger]) if options[:logger]
    end

    # Log a report about the sound
    # @param [IO] logger
    # @return [Boolean]
    def report(logger)
      logger.puts("Sound report for #{@audio_file.path}")
      logger.puts("  Sample rate: #{@audio_file.sample_rate}")
      logger.puts("  Channels: #{@audio_file.num_channels}")
      logger.puts("  File size: #{@audio_file.size}")
      true
    end

    private

    def populate(options = {})
      @data = @audio_file.read(options)
      @size = data.size
    end

  end

end
