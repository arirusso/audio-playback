module SamplePlayer

  class AudioStream < FFI::PortAudio::Stream

    def initialize(output)
      @muted = false
      @gain = 1.0
      @counter = 0
      @eof = false
      @input = nil
      @output = output
    end

    def play(sample)
      report(sample)
      open_sample(sample)
      start
      block
    end

    private

    def block
      until @eof do
        sleep(0.0001)
      end
      true
    end

    def open_sample(sample)
      open(@input, @output.resource, sample.sample_rate.to_i, sample.frame_size, API::NoFlag, sample.data)
      at_exit do
        puts "exit"
        close
        FFI::PortAudio::API.Pa_Terminate
      end
      true
    end

    def report(sample)
      puts "Sample rate: #{sample.sample_rate}"
      puts "Channels: #{sample.num_channels}"
      puts "File size: #{sample.size}"
      puts "Frame size: #{sample.frame_size}"
      puts "Latency: #{@output.latency}"
      self
    end

    def process(input, output, frames_per_buffer, timeInfo, statusFlags, user_data)
      #puts "--"
      #puts "Entering callback at #{Time.now.to_f}"
      sample_size = user_data.get_float32(0).to_i
      #puts "Sample size: #{sample_size}"
      if @counter >= sample_size - frames_per_buffer
        if @counter < sample_size
          frame_size = sample_size.divmod(frames_per_buffer).last
        else
          @eof = true
          exit
        end
      end
      frame_size ||= frames_per_buffer
      #puts "Frame: #{@counter}"
      #puts "Size per buffer: #{frames_per_buffer}"
      offset = (@counter + 1) * FFI::TYPE_FLOAT32.size
      data = user_data.get_array_of_float32(offset, frame_size)
      #puts "This buffer size: #{data.size}"
      output.write_array_of_float(data)
      @counter += frames_per_buffer
      #puts "Exiting callback at #{Time.now.to_f}"
      :paContinue
    end
  end

end
