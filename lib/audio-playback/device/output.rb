module AudioPlayback

  module Device
    # An output device
    class Output

      attr_reader :id, :name, :resource

      # All output devices
      # @return [Array<Output>]
      def self.all
        Device.outputs
      end

      # Prints ids and names of each device to standard out
      # @return [Array<String>]
      def self.list
        all.map do |device|
          name = "#{device.id}. #{device.name}"
          $>.puts(name)
          name
        end
      end

      # Streamlined console prompt that asks the user (via standard in) to select a device
      # When their input is received, the device is selected and enabled
      # @return [Output]
      def self.gets
        device = nil
        puts ""
        puts "Select an audio output..."
        while device.nil?
          list
          print "> "
          selection = $stdin.gets.chomp
          if selection != ""
            selection = Integer(selection) rescue nil
            device = all.find { |d| d.id == selection } unless selection.nil?
          end
        end
        device
      end

      # Select an output device by ID
      # @param [Integer] id
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

      # @param [Integer] id
      # @param [Hash] options
      # @option options [Float] :latency Device latency in seconds
      def initialize(id, options = {})
        # Init audio output resource
        AudioPlayback.ensure_initialized
        populate(id, options)
      end

      # Device latency in seconds
      # @return [Float]
      def latency
        @resource[:suggestedLatency]
      end

      # Number of channels the device supports
      # @return [Integer]
      def num_channels
        @resource[:channelCount]
      end

      # ID of the device
      # @return [Integer]
      def id
        @resource[:device]
      end

      private

      # The underlying resource info struct for this output
      # @return [FFI::PortAudio::API::PaDeviceInfo]
      def info
        @info ||= Device.device_info(id)
      end

      # Populate the output
      # @param [Integer] id
      # @param [Hash] options
      # @option options [Float] :latency
      # @return [FFI::PortAudio::API::PaStreamParameters]
      def populate(id, options = {})
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

end
