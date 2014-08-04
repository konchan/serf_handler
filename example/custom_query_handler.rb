# -*- coding: utf-8 -*-
# custome_event_handler.rb
# 
# for maintenance
#  Control services
#   serf event service_ctl "stop solr neuron-se1v1"
#  Control system shutdown or reboot
#   serf event system_ctl "shutdown lb"
require 'yaml'
require 'serf_handler'

class CustomQueryHandler < SerfHandler
  CMDFILE = "/etc/serf/cmd.yml"
  LOGFILE = "/var/log/serf/query_handler.log"

  def initialize
    super(LOGFILE)
    @cmds = YAML.load_file(CMDFILE)
  end

  def service_ctl
    info = {}
    STDIN.each_line do |line|
      info[:service_ctl_word], info[:target], info[:role_node], _ = line.split(' ')
    end
    command = @cmds["service"][info[:service_ctl_word]][info[:target]]
    re = Regexp.compile("#{@name}|#{@role}", Regexp::IGNORECASE)
    if re =~ info[:role_node]
      result = `#{command}`
      log "execute #{command} => result: #{$?}"
      if $?.to_s.include?("exit 0")
        if info[:service_ctl_word].downcase == "status"
          case result.encode("UTF-8")
          when /running/ then response("running")
          when /stopped/   then response("stopped")
          end
        else
          response("success")
        end
      else
        response("fail")
      end
    end
  end

  def system_ctl
    info = {}
    STDIN.each_line do |line|
      info[:system_ctl_word], info[:role_node], _ = line.split(' ')
    end
    command = @cmds["system"][info[:system_ctl_word]][@role]
    re = Regexp.compile("#{@name}|#{@role}", Regexp::IGNORECASE)
    if re =~ info[:role_node]
      system(command)
      log "execute #{command} => result: #{$?}"
      if $?.to_s.include?("exit 0")
        response("success")
      else
        response("fail")
      end
    end
  end
end

if __FILE__ == $0
  handler = SerfHandlerProxy.new
  handler.register('default', CustomQueryHandler.new)
  handler.run
end