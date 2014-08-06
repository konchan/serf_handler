# -*- coding: utf-8 -*-
# custome_event_handler.rb
#
# for maintenance
#  Control services
#   serf query -tag role=web status iis
#  Control system shutdown or reboot
#   serf event system_ctl 'shutdown lb'

require 'yaml'
require 'serf_handler'

# extended class processing serf custom queries
class CustomQueryHandler < SerfHandler
  CMDFILE = '/etc/serf/cmd.yml'
  LOGFILE = '/var/log/serf/query_handler.log'
  SERVICE_METHOD_NAME = %w( start stop restart reload status )
  SYSTEM_METHOD_NAME = %w( shutdown reboot )

  def initialize
    super(LOGFILE)
    @cmds = YAML.load_file(CMDFILE)
  end

  # generate start, stop, restart, reload, status methods.
  SERVICE_METHOD_NAME.each do |m|
    define_method(m) do
      info = {}
      STDIN.each_line { |line| info[:target], _ = line.split(' ') }
      execute_command @cmds['service']["#{m}"][info[:target]]
    end
  end

  # generate shutdown, reboot methods.
  SYSTEM_METHOD_NAME.each do |m|
    define_method(m) { execute_command @cmds['system']["#{m}"][@role] }
  end

  def execute_command(command)
    result = `#{command}`
    log "execute #{command} => result: #{$CHILD_STATUS}"
    result_response $CHILD_STATUS unless command.downcase.include?('status')
    status_response result if command.downcase.include?('status')
  end

  def result_response(result)
    if result.to_s.include?('exit 0')
      response('success')
    else
      response('fail')
    end
  end

  def status_response(result)
    case result.encode('UTF-8')
    when /実行中|running/ then response('running')
    when /停止|stopped/   then response('stopped')
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  handler = SerfHandlerProxy.new
  handler.register('default', CustomQueryHandler.new)
  handler.run
end
