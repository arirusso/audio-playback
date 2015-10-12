# Audio Playback

Play audio files at the command line or with Ruby

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

* *-l* Latency in seconds

* *-b* Buffer size eg 2048

* *-c* Output to the given channel(s).  Eg `-c 0,1` will direct the audio to channels 0 and 1

* *-o* Output device id or name

* *-v* Verbose

#### example:

`playback test/media/1-stereo-44100.wav -v -c 1`

### With Ruby

```ruby
playback = AudioPlayback.play("test/media/1-stereo-44100.wav", options[:channels] => [0,1])
playback.block
```

#### options:

* `:buffer_size` Buffer size eg 2048

* `:channels` Output to the given channel(s).  Eg `:channels => [0,1]` will direct the audio to channels 0 and 1

* `:latency` Latency in seconds

* `:logger` Logger object

* `:output_device` Output id or name

## License

Licensed under Apache 2.0, See the file LICENSE

Copyright (c) 2015 [Ari Russo](http://arirusso.com)
