module AudioPlayback

  # Using the AudioPlayback module from the command line
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

      :duration => {
        :short => "-d",
        :long => "--duration [seconds]",
        :name => "Duration",
        :type => String
      },

      :end_position => {
        :short => "-e",
        :long => "--end-position [seconds]",
        :name => "End position",
        :type => String
      },

      :latency => {
        :short => "-l",
        :long => "--latency [seconds]",
        :type => Float,
        :name => "Latency"
      },

      :list_devices => {
        :long => "--list-devices",
        :name => "List devices"
      },

      :seek => {
        :short => "-s",
        :long => "--seek [seconds]",
        :name => "Seek",
        :type => String
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
    }.freeze

  end

end
