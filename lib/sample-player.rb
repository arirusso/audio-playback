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
require "sample-player/file"
require "sample-player/output"
require "sample-player/playback"
require "sample-player/sound"
require "sample-player/stream"

module SamplePlayer

  VERSION = "0.0.1"

end
