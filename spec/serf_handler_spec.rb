require 'spec_helper'
require 'logger'

describe 'SerfHandler' do
  context 'Check initialize process & error method' do
    before do
      ENV['SERF_SELF_NAME'] = 'local'
      ENV['SERF_SELF_ROLE'] = 'web'
      ENV['SERF_EVENT'] = 'member-join'
    end

    it 'has handler name as local' do
      handler = SerfHandler.new
      expect(handler.name).to eq('local')
    end

    it 'has handler role as web' do
      handler = SerfHandler.new
      expect(handler.role).to eq('web')
    end

    it 'is set the event: member-join' do
      handler = SerfHandler.new
      expect(handler.event).to eq('member_join')
    end

    it 'write error' do
      logger = double('Logger')
      expect(logger).to receive(:level=).with(Logger::INFO)
      expect(logger).to receive(:error).with('Error occurred').and_return(true)
      handler = SerfHandler.new(logger)
      expect(handler.error('Error occurred')).to be true
    end

    it 'alias_method' do
      logger = double('Logger')
      expect(logger).to receive(:level=).with(Logger::INFO)
      expect(logger).to receive(:info).with('alias method test').and_return(true)
      handler = SerfHandler.new(logger)
      expect(handler.log('alias method test')).to be true
    end
  end

  context 'Check user event processing' do
    before do
      ENV['SERF_SELF_NAME'] = 'local'
      ENV['SERF_SELF_ROLE'] = 'web'
      ENV['SERF_EVENT'] = 'user'
      ENV['SERF_USER_EVENT'] = 'deploy'
    end

    it 'has custome event: user' do
      handler = SerfHandler.new
      expect(handler.event).to eq('deploy')
    end
  end
end

describe 'SerfHandlerProxy' do
  context 'Check Processing Tags' do
    before do
      ENV['SERF_SELF_NAME'] = nil
      ENV['SERF_TAG_ROLE'] = 'bob'
      ENV['SERF_EVENT'] = 'member-join'
    end

    it 'has the role as bob' do
      handler = SerfHandlerProxy.new
      expect(handler.role).to eq('bob')
    end
  end

  context 'Test negative cases' do
    before do
      ENV['SERF_TAG_ROLE'] = nil
      ENV['SERF_SELF_NAME'] = nil
      ENV['SERF_SELF_ROLE'] = nil
      ENV['SERF_EVENT'] = 'member-join'
    end

    it 'has no role' do
      logger = double('Logger')
      expect(logger).to receive(:level=).with(Logger::INFO)
      expect(logger).to receive(:info).with('no handler for role').and_return(true)
      handler = SerfHandlerProxy.new(logger)
      expect(handler.run).to be true
    end

    it 'has no method implemented' do
      logger = double('Logger')
      expect(logger).to receive(:level=).with(Logger::INFO)
      expect(logger).to receive(:warn).with('member_join event not implemented by class').and_return(true)
      handler = SerfHandlerProxy.new(logger)
      handler.register('default', SerfHandler.new)
      expect(handler.run).to be true
    end
  end

  context 'Test custom event' do
    before do
      ENV['SERF_SELF_NAME'] = nil
      ENV['SERF_SELF_ROLE'] = nil
      ENV['SERF_EVENT'] = 'user'
      ENV['SERF_USER_EVENT'] = 'implemented'
    end

    it 'has method to process custom event' do
      handler = SerfHandlerProxy.new
      sample = double('SerfHandler')
      expect(sample).to receive(:implemented).and_return(true)
      handler.register('default', sample)
      expect(handler.run).to be true
    end
  end

  context 'Test custom query' do
    before do
      ENV['SERF_SELF_NAME'] = nil
      ENV['SERF_SELF_ROLE'] = nil
      ENV['SERF_EVENT'] = 'query'
      ENV['SERF_QUERY_NAME'] = 'query_command'
    end

    it 'has method to process custom event' do
      handler = SerfHandlerProxy.new
      sample = double('SerfHandler')
      expect(sample).to receive(:query_command).and_return(true)
      handler.register('default', sample)
      expect(handler.run).to be true
    end

    it 'exceeds limitation' do
      handler = SerfHandler.new
      message = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed at purus sapien. Fusce vitae odio tristique, 
                 lacinia purus sed, dictum risus. Nullam rhoncus auctor sapien, nec interdum diam interdum sed. Nulla quis 
                 posuere justo. Donec porta, odio eget mollis laoreet, elit leo sollicitudin nisl, luctus vehicula velit 
                 erat eu est. Fusce ligula urna, blandit a iaculis nec, suscipit ut purus. Donec sed magna ac mi cursus 
                 faucibus. Maecenas vehicula turpis sit amet lacus cursus, quis ultricies nisi porta. Donec risus ligula, 
                 elementum eget est nec, vestibulum aliquet nisi. Sed lacinia adipiscing risus, id vulputate leo posuere in. 
                 Duis rutrum varius magna, eget feugiat orci tempor vel. Vestibulum massa lacus, dictum in rutrum tristique, 
                 varius ultrices neque. Donec fringilla odio eget elementum dignissim. Aliquam ut lectus neque.
                 Donec nec hendrerit dolor. Phasellus ac augue lobortis, vestibulum lacus at, ornare enim. Donec condimentum 
                 quis tellus vulputate auctor. Fusce eu tortor vel velit gravida eleifend id a lorem. Maecenas porta est vel 
                 sollicitudin ornare. Morbi et commodo diam, non congue nisi. Pellentesque mattis enim lobortis, hendrerit 
                 nulla eget, tempus diam. Donec orci aliquam.'
      expect{ handler.response(message) }.to output("message exceeds limit of 1024 bytes.\n").to_stdout
    end
  end

  context 'Test standard event when role is default' do
    before do
      ENV['SERF_SELF_NAME'] = nil
      ENV['SERF_EVENT'] = 'member-join'
    end

    it 'has method to process member_join event' do
      handler = SerfHandlerProxy.new
      sample = double('SerfHandler')
      expect(sample).to receive(:member_join).and_return(true)
      handler.register('default', sample)
      expect(handler.run).to be true
    end
  end

  context 'Test standard event when role is web' do
    before do
      ENV['SERF_SELF_NAME'] = nil
      ENV['SERF_SELF_ROLE'] = 'web'
      ENV['SERF_EVENT'] = 'member-join'
    end

    it 'has method to process member_join event' do
      handler = SerfHandlerProxy.new
      sample = double('SerfHandler')
      expect(sample).to receive(:member_join).and_return(true)
      handler.register('web', sample)
      expect(handler.run).to be true
    end
  end
end
