serf_handler
============
[![Build Status](https://travis-ci.org/konchan/serf_handler.svg?branch=master)](https://travis-ci.org/konchan/serf_handler)

[Serf](http://www.serfdom.io/) is a cluster orchestration framework which developed by [HashiCorp](http://www.hashicorp.com/). Serf allows you to execute your scripts when serf event occur.
You can simply extend SerfHandler and process serf events. Serf_handler is a very simple Ruby framework with no dependencies.
I have a lot in reference to [this code](https://github.com/garethr/serf-master).

### how to install

```
gem install serf_handler
```

### how to use

```sample.rb
#!/usr/bin/env ruby
require 'serf_handler'

class MyEventHandler
  # called by SerfHandler when member-join event occur
  def member_join
    # write your code
  end
end

if __FILE__ == $0
  handler = SerfHandlerProxy.new
  handler.register('MyRole', MyEventHandler.new)
  handler.run
end
```

### Contributing
- Fork it
- Create your feature branch (```git checkout -b my-new-feature```)
- Commit your changes (```git commit -am 'Add some feature'```)
- Push to the branch (```git push origin my-new-feature```)
- Create new Pull Request
