#!/usr/bin/env ruby
$:.unshift(File.join("..", "lib"))

# Print all of the output device names to the console

require "audio-playback"

AudioPlayback.list_devices
