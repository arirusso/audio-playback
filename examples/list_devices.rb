#!/usr/bin/env ruby
$:.unshift(File.join("..", "lib"))

# Print all of the output device names to the console

require "audio-playback"

AudioPlayback::Output.all.each do |output|
  puts "#{output.id}). #{output.name}"
end
