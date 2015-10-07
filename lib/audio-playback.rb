# AudioPlayback
#
# (c)2015 Ari Russo
# Apache 2.0 License

# libs
require "ffi-portaudio"
require "forwardable"
require "midi-eye"
require "ruby-audio"
require "unimidi"

# modules
require "audio-playback/device"
require "audio-playback/libc"

# classes
require "audio-playback/file"
require "audio-playback/output"
require "audio-playback/playback"
require "audio-playback/sound"
require "audio-playback/stream"

module AudioPlayback

  VERSION = "0.0.1"

  def self.play(filename, options = {})
    sound = Sound.load(filename, options)
    output = Output.find_by_name(options[:output]) || Output.find_by_id(options[:output]) || Device.default_output
    Playback.play(sound, output, options)
  end

  def self.ensure_initialized
    @initialized ||= FFI::PortAudio::API.Pa_Initialize
  end

end
