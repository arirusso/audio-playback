require "helper"

class AudioPlayback::DeviceTest < Minitest::Test

  context "Device" do

    setup do
      @outputs = AudioPlayback::Device.outputs
    end

    context ".outputs" do

      should "return available outputs" do
        refute_nil @outputs
        refute_empty @outputs
        assert_equal TestHelper::OUTPUT_INFO.map { |info| info[:name] }, @outputs.map(&:name)
      end

    end

    context ".output?" do

      should "return whether device is an output" do
        assert @outputs.all? { |output| AudioPlayback::Device.send(:output?, output.id) }
      end

    end

    context ".device_info" do

      should "return requested device info" do
        assert @outputs.all? do |output|
          info = AudioPlayback::Device.send(:device_info, output.id)
          TestHelper::OUTPUT_INFO.include?(info)
        end
      end

    end

    context ".find_by_id" do

      should "return an output with the given id" do
        @outputs.each do |output|
          assert_equal output, AudioPlayback::Device.find_by_id(output.id)
        end
      end

    end

    context ".find_by_name" do

      should "return an output with the given name" do
        @outputs.each do |output|
          assert_equal output, AudioPlayback::Device.find_by_name(output.name)
        end
      end

    end

    context ".default_output" do

      setup do
        @output = AudioPlayback::Device.default_output
      end

      should "return the default output" do
        refute_nil @output
        assert_equal TestHelper::DEFAULT_OUTPUT_ID, @output.id
      end

    end

  end

end
