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
require "audio-playback/libc"
require "audio-playback/thread"

# classes
require "audio-playback/file"
require "audio-playback/output"
require "audio-playback/playback"
require "audio-playback/sound"
require "audio-playback/stream"

module AudioPlayback

  VERSION = "0.0.1"

end
