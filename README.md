# Audio Playback

A command line and Ruby tool for playing audio files

Under the hood the *portaudio* and *libsndfile* libraries are used, enabling the gem to be cross-platform on any systems where these libraries are available

## Installation

These packages must be installed first:

* libsndfile ([link](https://github.com/erikd/libsndfile))
* portaudio ([link](http://portaudio.com/docs/v19-doxydocs/pages.html))

Both libraries are available in *Homebrew*, *APT*, *Yum* as well as many other package managers. For those who wish to compile themselves or need more information about those packages, follow the links above for more information

Once those libraries are installed, install the gem itself using

    gem install audio-playback

Or if you're using Bundler, add this to your Gemfile

    gem "audio-playback"

## Usage

### Command line

`playback [filename] [options]`

#### options:

* `-l` Latency in seconds.  Defaults to use the default latency for the selected output device

* `-b` Buffer size in bytes.  Defaults to 4096

* `-c` Output audio to the given channel(s).  Eg `-c 0,1` will direct audio to channels 0 and 1.  Defaults to use channels 0 and 1 on the selected device

* `-o` Output device id or name.  Defaults to the system default

* `-v` or `--verbose` Verbose

* `--list-devices` List the available audio output devices


#### example:

`playback test/media/1-stereo-44100.wav -v -c 1`

### With Ruby

```ruby
require "audio-playback"

# Prompt the user to select an audio output
@output = AudioPlayback::Device::Output.gets

options = {
  :channels => [0,1],
  :latency => 1,
  :output_device => @output
}

@playback = AudioPlayback.play("test/media/1-stereo-44100.wav", options)

# Play in the foreground
@playback.block

```

#### options:

* `:buffer_size` Buffer size in bytes.  Defaults to 4096

* `:channel` or `:channels` Output audio to the given channel(s).  Eg `:channels => [0,1]` will direct the audio to channels 0 and 1. Defaults to use channels 0 and 1 on the selected device

* `:latency` Latency in seconds.  Defaults to use the default latency for the selected output device

* `:logger` Logger object

* `:output_device` Output device id or name

#### More Examples

More Ruby code examples:

* [List devices](https://github.com/arirusso/audio-playback/blob/master/examples/list_devices.rb)
* [Select a file and play](https://github.com/arirusso/audio-playback/blob/master/examples/select_and_play.rb)
* [Play multiple files](https://github.com/arirusso/audio-playback/blob/master/examples/play_multiple.rb)


## License

Licensed under Apache 2.0, See the file LICENSE

Copyright (c) 2015 [Ari Russo](http://arirusso.com)
