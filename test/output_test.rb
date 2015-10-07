require "helper"

class AudioPlayback::OutputTest < Minitest::Test

  context "Output" do

    setup do
      @outputs = AudioPlayback::Output.all
    end

    context ".all" do

      should "return available outputs" do
        refute_nil @outputs
        refute_empty @outputs
        assert_equal TestHelper::OUTPUT_INFO.map { |info| info[:name] }, @outputs.map(&:name)
      end

    end

    context ".find_by_id" do

      should "return an output with the given id" do
        @outputs.each do |output|
          assert_equal output, AudioPlayback::Output.find_by_id(output.id)
        end
      end

    end

    context ".find_by_name" do

      should "return an output with the given name" do
        @outputs.each do |output|
          assert_equal output, AudioPlayback::Output.find_by_name(output.name)
        end
      end

    end

  end

end
