module AudioPlayback

  module Device

    def self.outputs
      AudioPlayback.ensure_initialized
      if @devices.nil?
        count = FFI::PortAudio::API.Pa_GetDeviceCount
        ids = (0..count-1).to_a.select { |id| output?(id) }
        @devices = ids.map { |id| Output.new(id) }
      end
      @devices
    end

    def self.output?(id)
      device_info(id)[:maxOutputChannels] > 0
    end

    def self.device_info(id)
      FFI::PortAudio::API.Pa_GetDeviceInfo(id)
    end

    def self.find_by_id(id)
      outputs.find { |device| [device, device.id].include?(id) }
    end

    def self.find_by_name(name)
      outputs.find { |device| device.name == name }
    end

    def self.default_output
      find_by_id(FFI::PortAudio::API.Pa_GetDefaultOutputDevice)
    end

  end

end
