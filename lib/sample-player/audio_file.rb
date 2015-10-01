module SamplePlayer

  class AudioFile

    attr_reader :num_channels, :sample_rate

    def initialize(filename)
      @file = RubyAudio::Sound.open(filename)
      @num_channels = @file.info.channels
      @sample_rate = @file.info.samplerate
    end

    def read(frame_size)
      puts "Reading audio file"
      buffer = RubyAudio::Buffer.float(frame_size, @num_channels)
      counter = 0
      ended = false
      data = []

      until ended do
        begin
          @file.seek(counter)
          @file.read(buffer, frame_size)
          data += buffer.to_a
          counter += frame_size
        rescue RubyAudio::Error
          ended = true
        end
      end
      puts "Finished reading audio file"
      data
    end

  end

end
