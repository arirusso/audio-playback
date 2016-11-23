module AudioPlayback

  module Device

    class Stream < FFI::PortAudio::Stream

      attr_reader :is_playing
      alias_method :playing?, :is_playing

      # Keep track of all streams
      # @return [Array<Stream>]
      def self.streams
        @streams ||= []
      end

      # @param [Output] output
      # @param [Hash] options
      # @option options [IO] logger
      def initialize(output, options = {})
        @is_playing = false
        @is_muted = false
        @gain = 1.0
        @input = nil
        @output = output.resource
        initialize_exit_callback(:logger => options[:logger])
        Stream.streams << self
      end

      # Perform the given playback
      # @param [Playback] playback
      # @param [Hash] options
      # @option options [IO] logger
      # @return [Stream]
      def play(playback, options = {})
        @is_playing = true
        report(playback, options[:logger]) if options[:logger]
        if @stream.nil?
          open_playback(playback)
        else
          continue(playback)
        end
        start
        self
      end

      # Is the stream active?
      # @return [Boolean]
      def active?
        FFI::PortAudio::API.Pa_IsStreamActive(@stream.read_pointer) == 1
      end

      # Block process until the current playback finishes
      # @return [Boolean]
      def block
        begin
          while active?
            sleep(0.001)
          end
          while FFI::PortAudio::API.Pa_IsStreamActive(@stream.read_pointer) != :paNoError
            sleep(0.1)
          end
        rescue SystemExit, Interrupt
          # Control-C
          @is_playing = false
          exit
        end
        @is_playing = false
        true
      end

      private

      # Open the stream resource for playback
      # @param [Playback] playback
      # @return [Boolean]
      def open_stream(playback)
        @userdata ||= playback.data.to_pointer
        FFI::PortAudio::API.Pa_OpenStream(@stream, @input, @output, @freq, @frames, @flags, @method, @userdata)
        true
      end

      # Reset the stream and continue playback
      # @param [Playback] playback
      # @return [Boolean]
      def continue(playback)
        playback.reset
        open_stream(playback)
        true
      end

      # Initialize the callback that's fired when the stream exits
      # @return [Stream]
      def initialize_exit_callback(options = {})
        at_exit { exit_callback(options) }
        self
      end

      # Callback that's fired when the stream exits
      # @return [Boolean]
      def exit_callback(options = {})
        logger = options[:logger]
        logger.puts("Exit") if logger
        unless @stream.nil?
          #close
          FFI::PortAudio::API.Pa_Terminate
        end
        @is_playing = false
        true
      end

      # Initialize the stream for playback
      # @param [Playback] playback
      # @return [Boolean]
      def open_playback(playback)
        populate_stream_playback(playback)
        open_stream(playback)
        true
      end

      # Initialize the stream's playback properties
      # @param [Playback] playback
      # @return [Boolean]
      def populate_stream_playback(playback)
        @freq ||= playback.sample_rate.to_i
        @frames ||= playback.buffer_size
        @flags ||= FFI::PortAudio::API::NoFlag
        @stream ||= FFI::Buffer.new(:pointer)
        @method ||= method(:process)
        true
      end

      # Report about the stream
      # @param [Playback] playback
      # @param [IO] logger
      # @return [Stream]
      def report(playback, logger)
        self
      end

      # Portaudio stream callback
      def process(input, output, frames_per_buffer, time_info, status_flags, user_data)
        #puts "--"
        #puts "Entering callback at #{Time.now.to_f}"
        counter = user_data.get_float32(Playback::METADATA.index(:pointer) * Playback::FRAME_SIZE).to_i
        #puts "Frame: #{counter}"
        audio_data_size = user_data.get_float32(Playback::METADATA.index(:size) * Playback::FRAME_SIZE).to_i
        #puts "Sample size: #{audio_data_size}"
        num_channels = user_data.get_float32(Playback::METADATA.index(:num_channels) * Playback::FRAME_SIZE).to_i
        #puts "Num Channels: #{num_channels}"
        start_frame = user_data.get_float32(Playback::METADATA.index(:start_frame) * Playback::FRAME_SIZE).to_i
        #puts "Start point: #{start_frame}"
        end_frame = user_data.get_float32(Playback::METADATA.index(:end_frame) * Playback::FRAME_SIZE).to_i
        #puts "Duration: #{duration}"
        is_looping = user_data.get_float32(Playback::METADATA.index(:is_looping) * Playback::FRAME_SIZE).to_i > 0
        #puts "Is looping: #{is_looping}"
        end_frame = [end_frame, audio_data_size].min
        is_eof = false
        if counter >= end_frame - frames_per_buffer
          if counter < end_frame
            buffer_size = end_frame.divmod(frames_per_buffer).last
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
        offset = (((counter + start_frame) * num_channels) + Playback::METADATA.count) * Playback::FRAME_SIZE
        #puts "Starting at location: #{offset}"
        data = user_data.get_array_of_float32(offset, buffer_size * num_channels)
        data += extra_data unless extra_data.nil?
        #puts "This buffer size: #{data.size}"
        #puts "Writing to output"
        output.write_array_of_float(data)
        counter += frames_per_buffer
        user_data.put_float32(Playback::METADATA.index(:pointer) * Playback::FRAME_SIZE, counter.to_f) # update counter
        if is_eof
          if is_looping
            #puts "Looping to beginning"
            user_data.put_float32(Playback::METADATA.index(:pointer) * Playback::FRAME_SIZE, start_frame)
            :paContinue
          else
            #puts "Marking eof"
            user_data.put_float32(Playback::METADATA.index(:is_eof) * Playback::FRAME_SIZE, 1.0) # mark eof
            :paComplete
          end
        else
          :paContinue
        end
        #puts "Exiting callback at #{Time.now.to_f}"
        result
      end
    end

  end

end
