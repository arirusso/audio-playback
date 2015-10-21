# Audio Playback

Play audio files at the command line or using Ruby

## Installation

These packages must be installed first:

* portaudio
* libsndfile

Install the gem using

    gem install audio-playback

Or if you're using Bundler, add this to your Gemfile

    gem "audio-playback"

## Usage

### Command line

`playback [filename] [options]`

#### options:

* `-l` Latency in seconds.  Defaults to use the default latency for the selected output device

* `-b` Buffer size in bytes.  Defaults to 4096

* `-c` Output audio to the given channel(s).  Eg `-c 0,1` will direct audio to channels 0 and 1.  Defaults to use all available channels

* `-o` Output device id or name.  Defaults to the system default

* `-v` or `--verbose` Verbose

* `--list-devices` List the available audio output devices


#### example:

`playback test/media/1-stereo-44100.wav -v -c 1`

### With Ruby

```ruby
require "audio-playback"

@output = AudioPlayback::Device::Output.gets

options = {
  :channels => [0,1],
  :latency => 1,
  :output_device => @output
}

@playback = AudioPlayback.play("test/media/1-stereo-44100.wav", options)

@playback.block

```

#### options:

* `:buffer_size` Buffer size in bytes.  Defaults to 4096

* `:channel` or `:channels` Output audio to the given channel(s).  Eg `:channels => [0,1]` will direct the audio to channels 0 and 1. Defaults to use all available channels

* `:latency` Latency in seconds.  Defaults to use the default latency for the selected output device

* `:logger` Logger object

* `:output_device` Output device id or name

## License

Licensed under Apache 2.0, See the file LICENSE

Copyright (c) 2015 [Ari Russo](http://arirusso.com)
