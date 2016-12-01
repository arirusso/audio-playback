#!/usr/bin/env ruby
$:.unshift(File.join("..", "lib"))

# Loop an audio file

require "audio-playback"

MEDIA_DIRECTORY = "../test/media"

# Select an output
@output = AudioPlayback::Device::Output.gets

# Find audio files
audio_files = Dir.entries(MEDIA_DIRECTORY)
audio_files.reject! { |file| file.match(/^\.{1,2}$/) }

# Select two random files
@file = audio_files.sample(2).first

# Play files
sound = AudioPlayback::Sound.load("#{MEDIA_DIRECTORY}/#{@file}")
@playback = AudioPlayback::Playback.new(sound, @output, is_looping: true)

@playback.start
@playback.block
