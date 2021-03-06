module AudioPlayback

  # An audio file
  class File

    attr_reader :num_channels, :path, :sample_rate, :size

    # @param [::File, String] file_or_path
    def initialize(file_or_path)
      @path = file_or_path.kind_of?(::File) ? file_or_path.path : file_or_path
      @file = RubyAudio::Sound.open(@path)
      @size = ::File.size(@path)
      @num_channels = @file.info.channels
      @sample_rate = @file.info.samplerate
    end

    # @param [Hash] options
    # @option options [IO] :logger
    # @return [Array<Array<Float>>, Array<Float>] File data
    def read(options = {})
      if logger = options[:logger]
        logger.send(:puts, "Reading audio file #{@path}")
      end
      buffer = RubyAudio::Buffer.float(@size, @num_channels)
      begin
        @file.seek(0)
        @file.read(buffer, @size)
        data = buffer.to_a
      rescue RubyAudio::Error
      end
      logger.send(:puts, "Finished reading audio file #{@path}") if logger
      data
    end

  end

end
