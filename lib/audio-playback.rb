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
require "midi-eye"
require "ruby-audio"
require "unimidi"

# modules
require "audio-playback/device"

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
    output = Output.by_name(options[:output_device]) || Output.by_id(options[:output_device]) || Device.default_output
    Playback.play(sound, output, options)
  end

  def self.ensure_initialized
    @initialized ||= FFI::PortAudio::API.Pa_Initialize
  end

end
