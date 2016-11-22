#
# AudioPlayback
# Play audio files at the command line or with Ruby
#
# (c)2015 Ari Russo
# Apache 2.0 License
# https://github.com/arirusso/audio-playback
#

# libs
require "ffi/libc"
require "ffi-portaudio"
require "forwardable"
require "ruby-audio"

# modules
require "audio-playback/device"
require "audio-playback/playback"

# classes
require "audio-playback/file"
require "audio-playback/sound"

# Play audio files
module AudioPlayback

  VERSION = "0.0.6"

  # Convenience method to play an audio file
  # @param [Array<::File>, Array<String>, ::File, String] file_paths
  # @param [Hash] options
  # @option options [Fixnum] :buffer_size Buffer size in bytes.  Defaults to 4096
  # @option options [Array<Fixnum>, Fixnum] :channels (or: :channel) Output audio to the given channel(s).  Eg `:channels => [0,1]` will direct the audio to channels 0 and 1. Defaults to use all available channels
  # @option options [Float] :latency Latency in seconds.  Defaults to use the default latency for the selected output device
  # @option options [IO] :logger Logger object
  # @option options [Fixnum, String] :output_device (or: :output) Output device id or name
  def self.play(file_paths, options = {})
    sounds = Array(file_paths).map { |path| Sound.load(path, options) }
    requested_device = options[:output_device] || options[:output]
    output = Device::Output.by_name(requested_device) || Device::Output.by_id(requested_device) || Device.default_output
    Playback.play(sounds, output, options)
  end

  # List the available audio output devices
  # @return [Array<String>]
  def self.list_devices
    Device::Output.list
  end

  # Ensure that the audio system is initialized
  # @return [Boolean]
  def self.ensure_initialized
    @initialized ||= FFI::PortAudio::API.Pa_Initialize
  end

end
