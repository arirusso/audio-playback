module AudioPlayback

  class Stream < FFI::PortAudio::Stream

    def initialize(output, options = {})
      @is_muted = false
      @gain = 1.0
      @input = nil
      @output = output.resource
      logger = options[:logger]
      at_exit do
        logger.puts("Exit") if logger
        close
        FFI::PortAudio::API.Pa_Terminate
      end
    end

    def play(playback, options = {})
      report(playback, options[:logger]) if options[:logger]
      open_playback(playback)
      start
      self
    end

    def active?
      FFI::PortAudio::API.Pa_IsStreamActive(@stream.read_pointer) == 1
    end

    def block
      while active?
        sleep(0.0001)
      end
      while FFI::PortAudio::API.Pa_IsStreamActive(@stream.read_pointer) != :paNoError
        sleep(1)
      end
      exit
      true
    end

    private

    def open_playback(playback)
      open(@input, @output, playback.sample_rate.to_i, playback.buffer_size, FFI::PortAudio::API::NoFlag, playback.data)
      true
    end

    def report(playback, logger)
      logger.puts("Playing #{playback.sound.audio_file.path} with latency: #{@output[:suggestedLatency]}")
      self
    end

    def process(input, output, frames_per_buffer, time_info, status_flags, user_data)
      #puts "--"
      #puts "Entering callback at #{Time.now.to_f}"
      counter = user_data.get_float32(Playback::METADATA.index(:pointer) * Playback::FRAME_SIZE).to_i
      #puts "Frame: #{counter}"
      sample_size = user_data.get_float32(Playback::METADATA.index(:size) * Playback::FRAME_SIZE).to_i
      #puts "Sample size: #{sample_size}"
      num_channels = user_data.get_float32(Playback::METADATA.index(:num_channels) * Playback::FRAME_SIZE).to_i
      #puts "Num Channels: #{num_channels}"
      is_eof = false
      if counter >= sample_size - frames_per_buffer
        if counter < sample_size
          buffer_size = sample_size.divmod(frames_per_buffer).last
          #puts "Truncated buffer size: #{buffer_size}"
          difference = frames_per_buffer - buffer_size
          #puts "Adding #{difference} frames of null audio"
          extra_data = [0] * difference * num_channels
          is_eof = true
        else
          return :paAbort
        end
      end
      buffer_size ||= frames_per_buffer
      #puts "Size per buffer per channel: #{frames_per_buffer}"
      offset = ((counter * num_channels) + Playback::METADATA.count) * Playback::FRAME_SIZE
      #puts "Starting at location: #{offset}"
      data = user_data.get_array_of_float32(offset, buffer_size * num_channels)
      data += extra_data unless extra_data.nil?
      #puts "This buffer size: #{data.size}"
      #puts "Writing to output"
      output.write_array_of_float(data)
      counter += frames_per_buffer
      user_data.put_float32(Playback::METADATA.index(:pointer) * Playback::FRAME_SIZE, counter.to_f) # update counter
      if is_eof
        #puts "Marking eof"
        user_data.put_float32(Playback::METADATA.index(:is_eof) * Playback::FRAME_SIZE, 1.0) # mark eof
        :paComplete
      else
        :paContinue
      end
      #puts "Exiting callback at #{Time.now.to_f}"
      result
    end
  end

end
