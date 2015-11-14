#!/usr/bin/env ruby
$:.unshift(File.join("..", "lib"))

# Playback multiple files simultaneously in one stream

require "audio-playback"

MEDIA_DIRECTORY = "../test/media"

# Select an output
@output = AudioPlayback::Device::Output.gets

# Find audio files
audio_files = Dir.entries(MEDIA_DIRECTORY)
audio_files.reject! { |file| file.match(/^\.{1,2}$/) }

# Select two random files
@files = audio_files.sample(2)

# Initialize
@sounds = @files.map { |filename| AudioPlayback::Sound.load("#{MEDIA_DIRECTORY}/#{filename}") }

@stream = nil
p @sounds.map(&:size)
@sounds.each_with_index do |sound, i|
p i
  @playback = AudioPlayback::Playback.new(@sounds[0], @output, :stream => @stream)
  @stream ||= @playback.stream

  # Start playback
  @playback.start

  # Play in foreground
  @playback.block

end
