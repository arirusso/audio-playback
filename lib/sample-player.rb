# SamplePlayer
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
require "sample-player/libc"
require "sample-player/thread"

# classes
require "sample-player/audio_file"
require "sample-player/audio_stream"
require "sample-player/context"
require "sample-player/sample"

module SamplePlayer

  VERSION = "0.0.1"

  # Shortcut to Context constructor
  def self.new(*args, &block)
    Context.new(*args, &block)
  end

end
