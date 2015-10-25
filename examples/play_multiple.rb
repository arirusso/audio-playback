#!/usr/bin/env ruby
$:.unshift(File.join("..", "lib"))

# Playback multiple files simultaneously

require "audio-playback"

MEDIA_DIRECTORY = "../test/media"

# Select an output
@output = AudioPlayback::Device::Output.gets

# Find audio files
audio_files = Dir.entries(MEDIA_DIRECTORY)
audio_files.reject! { |file| file.match(/^\.{1,2}$/) }

# Select two random files
@files = audio_files.last(2)

# Initialize
@sounds = @files.map { |filename| AudioPlayback::Sound.load("#{MEDIA_DIRECTORY}/#{filename}") }

@playback = AudioPlayback::Playback.new(@sounds, @output)

# Start playback
@playback.start

# Play in foreground
@playback.block
