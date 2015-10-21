#!/usr/bin/env ruby
$:.unshift(File.join("..", "lib"))

# Select one of the test files for playback

require "audio-playback"

MEDIA_DIRECTORY = "../test/media"

# Select an output
@output = AudioPlayback::Device::Output.gets

# find audio files
audio_files = Dir.entries(MEDIA_DIRECTORY)
audio_files.reject! { |file| file.match(/^\.{1,2}$/) }

puts
puts "Select an audio file..."

# print list of files
audio_files.each_with_index { |file, i| puts("#{i+1}. #{file}") }
puts

# prompt user to select a file
filename = nil
while filename.nil? do
  print("> ")
  choice = gets
  index = choice.chomp.to_i - 1
  filename = audio_files[index]
end

# play file
@playback = AudioPlayback.play("#{MEDIA_DIRECTORY}/#{filename}", :output_device => @output)
@playback.block
