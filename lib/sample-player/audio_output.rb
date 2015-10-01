module SamplePlayer

  class AudioOutput

    attr_reader :resource

    def initialize(channels)
      populate(channels)
    end

    def latency
      @resource[:suggestedLatency]
    end

    private

    def get_latency
      info = FFI::PortAudio::API.Pa_GetDeviceInfo(@resource[:device])
      info[:defaultHighOutputLatency]
    end

    def populate(channels)
      # Init audio output resource
      FFI::PortAudio::API.Pa_Initialize
      #
      @resource = FFI::PortAudio::API::PaStreamParameters.new
      @resource[:device]                    = FFI::PortAudio::API.Pa_GetDefaultOutputDevice
      @resource[:suggestedLatency]          = get_latency
      @resource[:hostApiSpecificStreamInfo] = nil
      @resource[:channelCount]              = channels
      @resource[:sampleFormat]              = FFI::PortAudio::API::Float32
      @resource
    end

  end

end
