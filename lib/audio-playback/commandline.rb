module AudioPlayback

  module Commandline

    OPTIONS = {
      :buffer_size => {
        :short => "-b",
        :long => "--buffer-size [bytes]",
        :type => Integer,
        :name => "Buffer size"
      },

      :channels => {
        :short => "-c",
        :long => "--channels [channel1, channel2]",
        :type => Array,
        :name => "Direct to channel(s)"
      },

      :latency => {
        :short => "-l",
        :long => "--latency [seconds]",
        :type => Float,
        :name => "Latency"
      },

      :logger => {
        :short => "-v",
        :long => "--verbose",
        :name => "Run verbosely",
        :when_true => $>
      },

      :output_device => {
        :short => "-o",
        :long => "--output [name or id]",
        :type => String,
        :name => "Output device for playback"
      }
    }

  end

end
