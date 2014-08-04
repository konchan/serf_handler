# -*- coding: utf-8 -*-
# @author katsuyuki
#
require "logger"

class SerfHandler
  attr :name, :role, :event

  def initialize(log=nil)
    if log
      if log.kind_of?(String)
        @logger = Logger.new(log)
      else
        @logger = log
      end
    else
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO
    end
    @name = ENV['SERF_SELF_NAME']
    @role = ENV['SERF_TAG_ROLE'] || ENV['SERF_SELF_ROLE']
    @event = case ENV['SERF_EVENT']
             when 'user'
               ENV['SERF_USER_EVENT']
             when 'query'
               ENV['SERF_QUERY_NAME']
             else
               ENV['SERF_EVENT'].gsub(/-/, '_')
             end
  end

  def log(msg)
    @logger.info(msg)
  end

  def response(msg)
    if msg.bytesize > 1024
      message = "message exceeds limit of 1024 bytes."
      log message
      puts message
    else
      puts msg
    end
  end
end

class SerfHandlerProxy < SerfHandler
  def initialize(log_file=nil)
    super(log_file)
    @handlers = {}
  end

  def register(role, handler)
    @handlers[role] = handler
  end

  def get_klass()
    klass = false
    if @handlers.include?(@role)
      klass = @handlers[@role]
    elsif @handlers.include?('default')
      klass = @handlers['default']
    end
    klass
  end

  def run()
    unless klass = get_klass
      log "no handler for role"
    else
      begin
        klass.send @event
      rescue NoMethodError => e
        log "#{@event} event not implemented by class"
      end
    end
  end
end
