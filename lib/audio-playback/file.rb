module AudioPlayback

  class File

    attr_reader :num_channels, :path, :sample_rate, :size

    def initialize(path)
      @path = path
      @file = RubyAudio::Sound.open(path)
      @size = ::File.size(path)
      @num_channels = @file.info.channels
      @sample_rate = @file.info.samplerate
    end

    def read
      puts "Reading audio file"
      buffer = RubyAudio::Buffer.float(@size, @num_channels)
      begin
        @file.seek(0)
        @file.read(buffer, @size)
        data = buffer.to_a
      rescue RubyAudio::Error
      end
      puts "Finished reading audio file"
      data
    end

  end

end
