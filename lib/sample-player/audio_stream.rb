module SamplePlayer

  class AudioStream < FFI::PortAudio::Stream

    def initialize(sample)
      @muted = false
      @gain = 1.0
      @counter = 0
      @eof = false
      @input = nil
      @sample = sample
      @output = Output.new(@sample.num_channels)

      report
      open
      start
      run
    end

    private

    def run
      until @eof do
        sleep(0.0001)
      end
    end

    def start
      at_exit do
        puts "exit"
        close
        FFI::PortAudio::API.Pa_Terminate
      end
      super
    end

    def open
      super(@input, @output.resource, @sample.sample_rate.to_i, @sample.frame_size, API::NoFlag, @sample.data)
    end

    def report
      puts "Sample rate: #{@sample.sample_rate}"
      puts "Channels: #{@sample.num_channels}"
      puts "File size: #{@sample.size}"
      puts "Frame size: #{@sample.frame_size}"
      puts "Latency: #{@output.latency}"
    end

    def process(input, output, frames_per_buffer, timeInfo, statusFlags, user_data)
      #puts "--"
      #puts "Entering callback at #{Time.now.to_f}"
      if @counter >= @sample.size - frames_per_buffer
        if @counter < @sample.size
          frame_size = @sample.size.divmod(frames_per_buffer).last
        else
          @eof = true
          exit
        end
      end
      frame_size ||= frames_per_buffer
      #puts "Frame: #{@counter}"
      #puts "Size per buffer: #{frames_per_buffer}"
      offset = @counter * FFI::TYPE_FLOAT32.size
      data = user_data.get_array_of_float32(offset, frame_size)
      #puts "Playing #{data.size} frames"
      output.write_array_of_float(data)
      @counter += frames_per_buffer
      #puts "Exiting callback at #{Time.now.to_f}"
      :paContinue
    end
  end

end
