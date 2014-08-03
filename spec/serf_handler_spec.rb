require 'spec_helper'

describe "SerfHandler" do
  context "Check initialize process" do
    before do
      ENV['SERF_SELF_NAME'] = 'local'
      ENV['SERF_SELF_ROLE'] = 'web'
      ENV['SERF_EVENT'] = 'member-join'
    end

    it "has handler name as 'local'" do
      handler = SerfHandler.new
      expect(handler.name).to eq('local')
    end

    it "has handler role as 'web'" do
      handler = SerfHandler.new
      expect(handler.role).to eq('web')
    end

    it "is set the event: 'member-join'" do
      handler = SerfHandler.new
      expect(handler.event).to eq('member_join')
    end
  end

  context "Check user event processing" do
    before do
      ENV['SERF_SELF_NAME'] = 'local'
      ENV['SERF_SELF_ROLE'] = 'web'
      ENV['SERF_EVENT'] = 'user'
      ENV['SERF_USER_EVENT'] = 'deploy'
    end

    it "has custome event: user" do
      handler = SerfHandler.new
      expect(handler.event).to eq('deploy')
    end
  end
end

describe "SerfHandlerProxy" do
  context "Check Processing Tags" do
    before do
      ENV['SERF_SELF_NAME'] = nil
      ENV['SERF_TAG_ROLE'] = 'bob'
      ENV['SERF_EVENT'] = 'member-join'
    end

    it "has the role as bob" do
      handler = SerfHandlerProxy.new
      expect(handler.role).to eq('bob')
    end
  end

  context "Test negative cases" do
    before do
      ENV['SERF_TAG_ROLE'] = nil
      ENV['SERF_SELF_NAME'] = nil
      ENV['SERF_SELF_ROLE'] = nil
      ENV['SERF_EVENT'] = 'member-join'
    end

    it "has no role" do
      logger = double('Logger')
      expect(logger).to receive(:info).with("no handler for role").and_return(true)
      handler = SerfHandlerProxy.new(logger)
      handler.run
    end

    it "has no method implemented" do
      logger = double('Logger')
      expect(logger).to receive(:info).with("member_join event not implemented by class").and_return(true)
      handler = SerfHandlerProxy.new(logger)
      handler.register('default', SerfHandler.new)
      handler.run
    end
  end

  context "Test custom event" do
    before do
      ENV['SERF_SELF_NAME'] = nil
      ENV['SERF_SELF_ROLE'] = nil
      ENV['SERF_EVENT'] = 'user'
      ENV['SERF_USER_EVENT'] = 'implemented'
    end

    it "has method to process custom event" do
      handler = SerfHandlerProxy.new
      sample = double('SerfHandler')
      expect(sample).to receive(:implemented).and_return(true)
      handler.register('default', sample)
      handler.run
    end
  end

  context "Test standard event when role is default" do
    before do
      ENV['SERF_SELF_NAME'] = nil
      ENV['SERF_EVENT'] = 'member-join'
    end

    it "has method to process member_join event" do
      handler = SerfHandlerProxy.new
      sample = double('SerfHandler')
      expect(sample).to receive(:member_join).and_return(true)
      handler.register('default', sample)
      handler.run
    end
  end

  context "Test standard event when role is web" do
    before do
      ENV['SERF_SELF_NAME'] = nil
      ENV['SERF_SELF_ROLE'] = 'web'
      ENV['SERF_EVENT'] = 'member-join'
    end

    it "has method to process member_join event" do
      handler = SerfHandlerProxy.new
      sample = double('SerfHandler')
      expect(sample).to receive(:member_join).and_return(true)
      handler.register('web', sample)
      handler.run
    end
  end
end
