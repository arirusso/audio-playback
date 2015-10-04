module AudioPlayback

  class Output

    attr_reader :id, :name, :resource

    def self.all
      Device.outputs
    end

    def self.find(id)
      Device.find(id)
    end

    def initialize(id, options = {})
      populate(id, options)
    end

    def latency
      @resource[:suggestedLatency]
    end

    def num_channels
      @resource[:channelCount]
    end

    def id
      @resource[:device]
    end

    private

    def info
      @info ||= Device.device_info(id)
    end

    def populate(id, options = {})
      # Init audio output resource
      AudioPlayback.ensure_initialized
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
