module AudioPlayback

  module Device

    extend self

    def outputs
      AudioPlayback.ensure_initialized
      if @devices.nil?
        count = FFI::PortAudio::API.Pa_GetDeviceCount
        ids = (0..count-1).to_a.select { |id| output?(id) }
        @devices = ids.map { |id| Output.new(id) }
      end
      @devices
    end

    def by_id(id)
      outputs.find { |device| [device, device.id].include?(id) }
    end

    def by_name(name)
      outputs.find { |device| device.name == name }
    end

    def default_output
      by_id(FFI::PortAudio::API.Pa_GetDefaultOutputDevice)
    end

    private

    def output?(id)
      device_info(id)[:maxOutputChannels] > 0
    end

    def device_info(id)
      FFI::PortAudio::API.Pa_GetDeviceInfo(id)
    end

  end

end
