module AudioPlayback

  class Output

    attr_reader :id, :name, :resource

    def self.all
      ensure_initialized
      if @devices.nil?
        count = FFI::PortAudio::API.Pa_GetDeviceCount
        @devices = (0..count-1).to_a.map { |id| new(id) }
      end
      @devices
    end

    def self.find(id)
      all.find { |device| [device, device.id].include?(id) }
    end

    def self.default
      find(FFI::PortAudio::API.Pa_GetDefaultOutputDevice)
    end

    def self.ensure_initialized
      @initialized ||= FFI::PortAudio::API.Pa_Initialize
    end

    def initialize(id, options = {})
      populate(id, options)
    end

    def latency
      @latency ||= @resource[:suggestedLatency]
    end

    def num_channels
      @num_channels ||= @resource[:channelCount]
    end

    def id
      @id ||= @resource[:device]
    end

    private

    def info
      @info ||= FFI::PortAudio::API.Pa_GetDeviceInfo(id)
    end

    def populate(id, options = {})
      # Init audio output resource
      self.class.ensure_initialized
      #
      @resource = FFI::PortAudio::API::PaStreamParameters.new
      @resource[:device]                    = id
      @name = info[:name]
      @resource[:suggestedLatency]          = info[:defaultHighOutputLatency]
      @resource[:hostApiSpecificStreamInfo] = nil
      @resource[:channelCount]              = options[:num_channels] || info[:maxOutputChannels]
      @resource[:sampleFormat]              = FFI::PortAudio::API::Float32
      @resource
    end

  end

end
