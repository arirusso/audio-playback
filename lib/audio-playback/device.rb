require "audio-playback/device/output"
require "audio-playback/device/stream"

module AudioPlayback

  # Audio IO devices
  module Device

    extend self

    # All output devices
    # @return [Array<Output>]
    def outputs
      AudioPlayback.ensure_initialized
      if @devices.nil?
        count = FFI::PortAudio::API.Pa_GetDeviceCount
        ids = (0..count-1).to_a.select { |id| output?(id) }
        @devices = ids.map { |id| Output.new(id) }
      end
      @devices
    end

    # Get a device by its ID
    # @param [Integer] id
    # @return [Output]
    def by_id(id)
      outputs.find { |device| [device, device.id].include?(id) }
    end

    # Get a device by its name
    # @param [String] name
    # @return [Output]
    def by_name(name)
      outputs.find { |device| device.name == name }
    end

    # The system default output
    # @return [Output]
    def default_output
      by_id(FFI::PortAudio::API.Pa_GetDefaultOutputDevice)
    end

    # Get system device info given a device ID
    # @param [Integer] id
    # @return [FFI::PortAudio::API::PaDeviceInfo]
    def device_info(id)
      FFI::PortAudio::API.Pa_GetDeviceInfo(id)
    end

    private

    # Is the device with the given ID an output?
    # @param [Integer] id
    # @return [Boolean]
    def output?(id)
      device_info(id)[:maxOutputChannels] > 0
    end

  end

end
