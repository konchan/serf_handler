# -*- coding: utf-8 -*-
# custome_event_handler.rb
# 
# for maintenance
#  Control services
#   serf query -tag role=web status iis
#  Control system shutdown or reboot
#   serf event system_ctl "shutdown lb"

require 'yaml'
require 'serf_handler'

class CustomQueryHandler < SerfHandler
  CMDFILE = "/etc/serf/cmd.yml"
  LOGFILE = "/var/log/serf/query_handler.log"
  SERVICE_METHOD_NAME = [ "start", "stop", "restart", "reload", "status" ]
  SYSTEM_METHOD_NAME = [ "shutdown", "reboot" ]

  def initialize
    super(LOGFILE)
    @cmds = YAML.load_file(CMDFILE)
  end

  # generate start, stop, restart, reload, status methods.
  SERVICE_METHOD_NAME.each do |m|
    define_method(m) do
      info = {}
      STDIN.each_line do |line|
        info[:target], _ = line.split(' ')
      end
      execute_command @cmds["service"]["#{m}"][info[:target]]
    end
  end

  # generate shutdown, reboot methods.
  SYSTEM_METHOD_NAME.each do |m|
    define_method(m) { execute_command @cmds["system"]["#{m}"] }
  end

  def execute_command(command)
    result = `#{command}`
    log "execute #{command} => result: #{$?}"
    if $?.to_s.include?("exit 0")
      if command.downcase.include?("status")
        case result.encode("UTF-8")
        when /実行中|running/ then response("running")
        when /停止|stopped/   then response("stopped")
        end
      else
        response("success")
      end
    else
      response("fail")
    end
  end
end

if __FILE__ == $0
  handler = SerfHandlerProxy.new
  handler.register('default', CustomQueryHandler.new)
  handler.run
end
