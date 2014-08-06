# -*- coding: utf-8 -*-
# @author katsuyuki
#
require 'logger'

# Base class for processing serf events
class SerfHandler
  attr_reader :name, :role, :event

  def initialize(log_file = nil)
    @logger = create_logger(log_file)
    @logger.level = Logger::INFO
    @name = ENV['SERF_SELF_NAME']
    @role = ENV['SERF_TAG_ROLE'] || ENV['SERF_SELF_ROLE']
    @event = case ENV['SERF_EVENT']
             when 'user'  then ENV['SERF_USER_EVENT']
             when 'query' then ENV['SERF_QUERY_NAME']
             else              ENV['SERF_EVENT'].gsub(/-/, '_')
             end
  end

  def create_logger(log_file)
    if log_file
      log_file.is_a?(String) ? Logger.new(log_file) : log_file
    else
      Logger.new(STDOUT)
    end
  end

  def log(msg)
    @logger.info(msg)
  end

  def response(msg)
    if msg.bytesize > 1024
      message = 'message exceeds limit of 1024 bytes.'
      log message
      puts message
    else
      puts msg
    end
  end
end

# Proxy for handling serf event
class SerfHandlerProxy < SerfHandler
  def initialize(log_file = nil)
    super(log_file)
    @handlers = {}
  end

  def register(role, handler)
    @handlers[role] = handler
  end

  def good_handler
    handler = nil
    if @handlers.include?(@role)
      handler = @handlers[@role]
    elsif @handlers.include?('default')
      handler = @handlers['default']
    end
    handler
  end

  def run
    if (the_handler = good_handler)
      begin
        the_handler.send @event
      rescue NoMethodError
        log "#{@event} event not implemented by class"
      end
    else
      log 'no handler for role'
    end
  end
end
