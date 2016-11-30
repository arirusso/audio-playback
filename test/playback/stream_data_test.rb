require "helper"

class AudioPlayback::Playback::StreamDataTest < Minitest::Test

  context "StreamData" do

    setup do
      @path = "test/media/1-mono-44100.wav"
      @file = AudioPlayback::File.new(@path)
      @sound = AudioPlayback::Sound.new(@file)
      @output = MockOutput.new(1, :num_channels => 1)
      @playback = AudioPlayback::Playback.new(@sound, @output, :stream => MockStream.new(@output))
    end

    context "#add_metadata" do

      setup do
        @data = AudioPlayback::Playback::StreamData.new(@playback)
      end

      should "add default metadata" do
        assert_equal 0.0, @data[AudioPlayback::Playback::METADATA.index(:is_eof)]
        assert_equal 0.0, @data[AudioPlayback::Playback::METADATA.index(:start_frame)]
        assert_equal 0.0, @data[AudioPlayback::Playback::METADATA.index(:pointer)]
        assert_equal @data.num_frames.to_f, @data[AudioPlayback::Playback::METADATA.index(:end_frame)]
        assert_equal @data.num_frames.to_f, @data[AudioPlayback::Playback::METADATA.index(:size)]
        assert_equal @playback.output.num_channels.to_f, @data[AudioPlayback::Playback::METADATA.index(:num_channels)]
      end

    end

    context "#set_metadata" do

      setup do
        @data = AudioPlayback::Playback::StreamData.new(@playback)

        # Validate
        @pointer_index = AudioPlayback::Playback::METADATA.index(:pointer)
        @eof_index = AudioPlayback::Playback::METADATA.index(:is_eof)

        assert_equal 0.0, @data[@pointer_index]
        assert_equal 0.0, @data[@eof_index]

        # Set metadata to non zero values
        @data.send(:set_metadata, :pointer, 4.0)
        @data.send(:set_metadata, :is_eof, 1.0)
      end

      should "change values" do
        assert_equal 4.0, @data[@pointer_index]
        assert_equal 1.0, @data[@eof_index]
      end

    end

    context "#reset" do

      setup do
        @data = AudioPlayback::Playback::StreamData.new(@playback)

        # Set metadata to non zero values
        @data.send(:set_metadata, :pointer, 4.0)
        @data.send(:set_metadata, :is_eof, 1.0)

        # Validate metadata
        indexes = [:pointer, :is_eof].map do |key|
          AudioPlayback::Playback::METADATA.index(key)
        end
        @nonzero_values = indexes.map { |index| @data[index] }
        assert @nonzero_values.all? { |value| value > 0.0 }

        # Run reset
        @data.reset

        # Collect metadata
        @reset_values = indexes.map { |index| @data[index] }
      end

      should "reset data" do
        refute_empty @reset_values
        assert @reset_values.all? { |value| value == 0.0 }
      end

    end

    context "#to_pointer" do

      setup do
        @data = AudioPlayback::Playback::StreamData.new(@playback)
        @pointer = @data.to_pointer
      end

      should "return a ffi pointer" do
        refute_nil @pointer
        assert_kind_of FFI::Pointer, @pointer
      end

    end

    context ".to_pointer" do

      setup do
        @pointer = AudioPlayback::Playback::StreamData.to_pointer(@playback)
      end

      should "return a ffi pointer" do
        refute_nil @pointer
        assert_kind_of FFI::Pointer, @pointer
      end

    end

  end

end
