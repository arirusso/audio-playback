require "helper"

class AudioPlayback::PositionTest < Minitest::Test

  context "Position" do

    context "#initialize" do

      context "invalid" do

        context "invalid number" do

          should "raise exception if min above 60" do
            assert_raises AudioPlayback::Position::InvalidTime do
              AudioPlayback::Position.new("123:78:34.45")
            end
          end

          should "raise exception if seconds above 60" do
            assert_raises AudioPlayback::Position::InvalidTime do
              AudioPlayback::Position.new("123:45:89.45")
            end
          end

        end

        context "other characters" do

          should "raise exception" do
            assert_raises AudioPlayback::Position::InvalidTime do
              AudioPlayback::Position.new("kdjfdkdj")
            end
          end

        end

      end

      context "valid" do

        context "has seconds integer" do

          should "populate ss" do
            position = AudioPlayback::Position.new("12")
            assert_equal 12.0, position.to_seconds
          end

          should "populate m:ss" do
            position = AudioPlayback::Position.new("3:45")
            assert_equal 225.0, position.to_seconds
          end

          should "populate mm:ss" do
            position = AudioPlayback::Position.new("06:07")
            assert_equal 367.0, position.to_seconds
          end

          should "populate h:mm:ss" do
            position = AudioPlayback::Position.new("8:09:10")
            assert_equal 29350.0, position.to_seconds
          end

          should "populate hh:mm:ss" do
            position = AudioPlayback::Position.new("11:12:13")
            assert_equal 40333.0, position.to_seconds
          end

        end

        context "has seconds float" do

          context "one digit" do

            should "populate ss.s" do
              position = AudioPlayback::Position.new("01.2")
              assert_equal 1.2, position.to_seconds
            end

            should "populate m:ss.s" do
              position = AudioPlayback::Position.new("3:45.6")
              assert_equal 225.6, position.to_seconds
            end

            should "populate mm:ss.s" do
              position = AudioPlayback::Position.new("07:59.1")
              assert_equal 479.1, position.to_seconds
            end

            should "populate h:mm:ss.s" do
              position = AudioPlayback::Position.new("1:23:45.6")
              assert_equal 5025.6, position.to_seconds
            end

            should "populate hh:mm:ss.s" do
              position = AudioPlayback::Position.new("12:34:56.7")
              assert_equal 45296.7, position.to_seconds
            end

          end

          context "two digit" do

            should "populate ss.ss" do
              position = AudioPlayback::Position.new("01.23")
              assert_equal 1.23, position.to_seconds
            end

            should "populate m:ss.ss" do
              position = AudioPlayback::Position.new("3:45.76")
              assert_equal 225.76, position.to_seconds
            end

            should "populate mm:ss.ss" do
              position = AudioPlayback::Position.new("07:59.12")
              assert_equal 479.12, position.to_seconds
            end

            should "populate h:mm:ss.ss" do
              position = AudioPlayback::Position.new("1:23:45.67")
              assert_equal 5025.67, position.to_seconds
            end

            should "populate hh:mm:ss.ss" do
              position = AudioPlayback::Position.new("12:34:56.78")
              assert_equal 45296.78, position.to_seconds
            end

          end

          context "three+ digits" do

            should "populate ss.ss" do
              position = AudioPlayback::Position.new("01.234")
              assert_equal 1.234, position.to_seconds
            end

            should "populate m:ss.ss" do
              position = AudioPlayback::Position.new("3:45.678")
              assert_equal 225.678, position.to_seconds
            end

            should "populate mm:ss.ss" do
              position = AudioPlayback::Position.new("07:39.123")
              assert_equal 459.123, position.to_seconds
            end

            should "populate h:mm:ss.ss" do
              position = AudioPlayback::Position.new("1:23:45.678")
              assert_equal 5025.678, position.to_seconds
            end

            should "populate hh:mm:ss.ss" do
              position = AudioPlayback::Position.new("12:34:56.789")
              assert_equal 45296.789, position.to_seconds
            end

          end

        end

      end

    end

  end

end
