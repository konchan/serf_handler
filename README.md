serf_handler
============
[![Build Status](https://travis-ci.org/konchan/serf_handler.svg?branch=master)](https://travis-ci.org/konchan/serf_handler)

[Serf](http://www.serfdom.io/) is a cluster orchestration framework which developed by [HashiCorp](http://www.hashicorp.com/). Serf allows you to execute your scripts when serf event occurs.
You can simply extend SerfHandler and process serf events. Serf_handler is a very simple Ruby framework with no dependencies.
I have a lot in reference to [this code](https://github.com/garethr/serf-master).

### how to install

```
gem install serf_handler
```

### how to use

```ruby
#!/usr/bin/env ruby
require 'serf_handler'

class MyEventHandler < SerfHandler
  def initialize
    # if logfile not specified, log outputs to STDOUT.
    super("/path/to/logfile")
  end
  
  # called by SerfHandlerProxy when member-join event occurs
  def member_join
    info "start processing member-join event"
    # other methods to write log: warn, error
    
    # write your code
  end
  
  # called by SerfHandlerProxy when your custome event occurs
  def your_custome_event
    info "start processing custom event"
    # other methods to write log: warn, error

    # write your code
  end
  
  # called by SerfHandlerProxy when you issue custom query
  # ex. serf query your_query_name "PAYLOAD"
  def your_query_name
    # write your code
    
    reponse("query reponse message you want to return")
    # if reponse message exceeds 1024 bytes limitation,
    # SerfHandler returns "message exceeds limit of 1024 bytes." to serf query client.
    # if you implement the methods for queries,
    # you have to set logfile.
    # serf query command returns output of stdout/stderr.
  end
end

if __FILE__ == $0
  handler = SerfHandlerProxy.new
  handler.register('MyRole', MyEventHandler.new)
  # another code
  # handler.regiter('default', MyEventHandler.new)
  handler.run
end
```

### Contributing
1. Fork it
2. Create your feature branch (```git checkout -b my-new-feature```)
3. Commit your changes (```git commit -am 'Add some feature'```)
4. Push to the branch (```git push origin my-new-feature```)
5. Create new Pull Request
