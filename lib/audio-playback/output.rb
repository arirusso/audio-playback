module AudioPlayback

  # An output device
  class Output

    attr_reader :id, :name, :resource

    # All output devices
    # @return [Array<Output>]
    def self.all
      Device.outputs
    end

    # Select an output device by ID
    # @param [Fixnum] id
    # @return [Output]
    def self.by_id(id)
      Device.by_id(id)
    end

    # Select an output device by name
    # @param [String] name
    # @return [Output]
    def self.by_name(name)
      Device.by_name(name)
    end

    # @param [Fixnum] id
    # @param [Hash] options
    # @option options [Float] :latency Device latency in seconds
    def initialize(id, options = {})
      populate(id, options)
    end

    # Device latency in seconds
    # @return [Float]
    def latency
      @resource[:suggestedLatency]
    end

    # Number of channels the device supports
    # @return [Fixnum]
    def num_channels
      @resource[:channelCount]
    end

    # ID of the device
    # @return [Fixnum]
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
