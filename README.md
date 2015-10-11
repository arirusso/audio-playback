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

* -l latency
* -b buffer size eg 2048
* -c num channels (must be equal or less to what the output supports)
* -o output id or name
* -v verbose output

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
