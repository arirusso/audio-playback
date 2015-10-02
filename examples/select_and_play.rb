#!/usr/bin/env ruby
$:.unshift(File.join("..", "lib"))

# Select one of the test files for playback

require "audio-playback"

MEDIA_DIRECTORY = "../test/media"

# find audio files
audio_files = Dir.entries(MEDIA_DIRECTORY)
audio_files.reject! { |file| file.match(/^\.{1,2}$/) }

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
playback = AudioPlayback.play("#{MEDIA_DIRECTORY}/#{filename}")
playback.block
