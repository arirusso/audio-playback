module SamplePlayer

  class AudioStream < FFI::PortAudio::Stream

    def initialize(output)
      @muted = false
      @gain = 1.0
      @eof = false
      @input = nil
      @output = output.resource
      at_exit do
        puts "exit"
        close
        FFI::PortAudio::API.Pa_Terminate
      end
    end

    def play(sample)
      playback = Playback.new(sample)
      report(playback)
      open_playback(playback)
      start
    end

    def block
      loop do
        sleep(0.0001)
      end
      true
    end

    private

    def open_playback(playback)
      open(@input, @output, playback.sample_rate.to_i, playback.frame_size, API::NoFlag, playback.data)
      true
    end

    def report(playback)
      puts "Playing #{playback.sample.audio_file.path} with latency: #{@output[:suggestedLatency]}"
      self
    end

    def process(input, output, frames_per_buffer, timeInfo, statusFlags, user_data)
      #puts "--"
      #puts "Entering callback at #{Time.now.to_f}"
      counter = user_data.get_float32(0).to_i
      #puts "Frame: #{counter}"
      sample_size = user_data.get_float32(2 * FFI::TYPE_FLOAT32.size).to_i
      #puts "Sample size: #{sample_size}"
      if counter >= sample_size - frames_per_buffer
        if counter < sample_size
          frame_size = sample_size.divmod(frames_per_buffer).last
        else
          user_data.put_float32(1, 1.0)
          exit
        end
      end
      frame_size ||= frames_per_buffer
      #puts "Size per buffer: #{frames_per_buffer}"
      offset = (counter + Playback::NUM_METADATA_BYTES) * FFI::TYPE_FLOAT32.size
      data = user_data.get_array_of_float32(offset, frame_size)
      #puts "This buffer size: #{data.size}"
      output.write_array_of_float(data)
      counter += frames_per_buffer
      user_data.put_float32(0, counter.to_f) # mark eof

      #puts "Exiting callback at #{Time.now.to_f}"
      :paContinue
    end
  end

end
