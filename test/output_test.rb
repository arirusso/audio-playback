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

    context "#populate" do

      setup do
        @output = AudioPlayback::Output.new(0)
      end

      should "populate id" do
        refute_nil @output.id
        assert_kind_of Fixnum, @output.id
      end

      should "populate latency" do
        refute_nil @output.latency
        assert_kind_of Numeric, @output.latency
      end

      should "populate number of channels" do
        refute_nil @output.num_channels
        assert_kind_of Fixnum, @output.num_channels
      end

    end

    context "#latency" do

      setup do
        @test_id = (0..TestHelper::OUTPUT_INFO.size-1).to_a.sample
        @test_info = TestHelper::OUTPUT_INFO[@test_id]
        @output = AudioPlayback::Output.new(@test_id)
      end

      should "return correct latency" do
        refute_nil @output.latency
        assert_kind_of Fixnum, @output.latency
        assert_equal @test_info[:defaultHighOutputLatency], @output.latency
      end

    end

    context "#num_channels" do

      setup do
        @test_id = (0..TestHelper::OUTPUT_INFO.size-1).to_a.sample
        @test_info = TestHelper::OUTPUT_INFO[@test_id]
        @output = AudioPlayback::Output.new(@test_id)
      end

      should "return correct num_channels" do
        refute_nil @output.num_channels
        assert_kind_of Fixnum, @output.num_channels
        assert_equal @test_info[:maxOutputChannels], @output.num_channels
      end

    end

    context "#id" do

      setup do
        @test_id = (0..TestHelper::OUTPUT_INFO.size-1).to_a.sample
        @output = AudioPlayback::Output.new(@test_id)
      end

      should "return correct id" do
        refute_nil @output.id
        assert_kind_of Fixnum, @output.id
        assert_equal @test_id, @output.id
      end

    end

  end

end
