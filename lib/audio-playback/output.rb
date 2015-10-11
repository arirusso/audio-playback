module AudioPlayback

  class Output

    attr_reader :id, :name, :resource

    def self.all
      Device.outputs
    end

    def self.by_id(id)
      Device.by_id(id)
    end

    def self.by_name(name)
      Device.by_name(name)
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
      @resource[:device] = id
      @name = info[:name]
      @resource[:suggestedLatency] = options[:latency] || info[:defaultHighOutputLatency]
      @resource[:hostApiSpecificStreamInfo] = nil
      @resource[:channelCount] = info[:maxOutputChannels]
      @resource[:sampleFormat] = FFI::PortAudio::API::Float32
      @resource
    end

  end

end
