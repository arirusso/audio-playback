module AudioPlayback

  # A time position in a sound
  class Position

    class InvalidTime < RuntimeError
    end

    extend Forwardable

    UNITS = [
      1, # second
      60, # minute
      3600 # hour
    ].freeze

    # Time format like (hh:)(mm:)ss(.ss)
    FORMAT = /((\d+\:)(\d{2}\:)|(\d{2}\:))?\d{1,2}(\.\d+)?/.freeze

    attr_reader :seconds
    alias_method :to_seconds, :seconds
    def_delegators :@seconds, :to_f

    # @param [Numeric, String] seconds_or_time Time as (hh:)(mm:)ss(.ss)
    def initialize(seconds_or_time)
      seconds_or_time = seconds_or_time.to_s
      validate_time(seconds_or_time)
      populate(seconds_or_time)
    end

    # Multiply the seconds value of this Position by the given value
    # @param [Numeric, Position] another
    # @return [Float]
    def *(another)
      @seconds * another.to_f
    end

    # Add the seconds value of this Position to the given value
    # @param [Numeric, Position] another
    # @return [Float]
    def +(another)
      @seconds + another.to_f
    end

    private

    # Validate that the time that was passed into the constructor is in the correct
    # format. Raises InvalidTime error if not
    # @param [Numeric, String] seconds_or_time Time as (hh:)(mm:)ss(.ss)
    # @return [Boolean]
    def validate_time(seconds_or_time)
      unless seconds_or_time.match(FORMAT)
        raise(InvalidTime)
      end
      true
    end

    # Validate that the segments of the time that was passed into the constructor
    # are valid. For example that the minutes and or seconds values are below 60.
    # Raises InvalidTime error if not
    # @param [Array<String>] segments Time as [(hh), (mm), ss(.ss)]
    # @return [Boolean]
    def validate_segments(segments)
      seconds = segments[0]
      minutes = segments[1]
      [seconds, minutes].compact.each do |segment|
        if segment >= 60
          raise(InvalidTime)
        end
      end
      true
    end

    # Populate the seconds ivar using the time that was passed into the constructor
    # @param [Numeric, String] seconds_or_time Time as (hh:)(mm:)ss(.ss)
    # @return [Float]
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
