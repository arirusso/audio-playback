module AudioPlayback

  class Position

    class InvalidTime < RuntimeError
    end

    extend Forwardable

    UNITS = [
      1, # second
      60, # minute
      3600 # hour
    ].freeze

    FORMAT = /((\d+\:)(\d{2}\:)|(\d{2}\:))?\d{1,2}(\.\d+)?/.freeze

    attr_reader :seconds
    alias_method :to_seconds, :seconds
    def_delegators :@seconds, :to_f

    def initialize(seconds_or_time)
      seconds_or_time = seconds_or_time.to_s
      validate_time(seconds_or_time)
      populate(seconds_or_time)
    end

    def *(another)
      @seconds * another.to_f
    end

    def +(another)
      @seconds + another.to_f
    end

    private

    def validate_time(seconds_or_time)
      unless seconds_or_time.match(FORMAT)
        raise(InvalidTime)
      end
    end

    def validate_segments(segments)
      seconds = segments[0]
      minutes = segments[1]
      [seconds, minutes].compact.each do |segment|
        if segment >= 60
          raise(InvalidTime)
        end
      end
    end

    def populate(seconds_or_time)
      segments = seconds_or_time.split(":").map(&:to_f).reverse
      validate_segments(segments)
      @seconds = 0
      segments.each_with_index do |segment, i|
        @seconds += segment * UNITS[i]
      end
      @seconds
    end

  end

end
