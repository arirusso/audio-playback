#!/usr/bin/env ruby
$:.unshift(File.join("..", "lib"))

# Print all of the output device names to the console

require "audio-playback"

AudioPlayback::Device::Output.all.each do |output|
  puts "#{output.id}). #{output.name}"
end
