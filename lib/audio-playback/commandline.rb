module AudioPlayback

  module Commandline

    OPTIONS = {
      :buffer_size => {
        :short => "-b",
        :long => "--buffer-size [bytes]",
        :type => Integer,
        :name => "Buffer size"
      },

      :num_channels => {
        :short => "-c",
        :long => "--num-channels [number]",
        :type => Integer,
        :name => "Number of channels"
      },

      :to_channels => {
        :short => "-d",
        :long => "--direct [channel1, channel2]",
        :type => Array,
        :name => "Direct to channel(s)"
      },

      :latency => {
        :short => "-l",
        :long => "--latency [millis]",
        :type => Float,
        :name => "Latency"
      },

      :output => {
        :short => "-o",
        :long => "--output [name or id]",
        :type => String,
        :name => "Output device for playback"
      },

      :logger => {
        :short => "-v",
        :long => "--verbose",
        :name => "Run verbosely",
        :when_true => $>
      }
    }

  end

end
