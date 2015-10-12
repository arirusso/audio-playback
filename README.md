# Audio Playback

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

* *-l* Latency in millis

* *-b* Buffer size eg 2048

* *-c* Number of channels.  Must be equal or less to the number of channels that the output supports.

* *-d* Direct output to the given channel(s).  Eg `-d 0,1` will direct the audio to channels 0 and 1

* *-o* Output id or name

* *-v* Verbose

#### example:

`playback test/media/1-stereo-44100.wav -v -c 1`

### Ruby

```ruby
playback = AudioPlayback.play("test/media/1-stereo-44100.wav", options[:num_channels] => 1)
playback.block
```

## License

Licensed under Apache 2.0, See the file LICENSE

Copyright (c) 2015 [Ari Russo](http://arirusso.com)
