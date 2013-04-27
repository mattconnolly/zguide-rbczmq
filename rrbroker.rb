#!/usr/bin/env ruby
require 'rbczmq'

context = ZMQ::Context.new

frontend = context.socket ZMQ::ROUTER
backend = context.socket ZMQ::DEALER
frontend.bind 'tcp://*:5559'
backend.bind 'tcp://*:5560'

class FrontEnd < ZMQ::Handler
  def initialize(pollitem, frontend, backend)
    super
    @frontend = frontend
    @backend = backend
  end
  def on_readable
    message = @frontend.recv_message
    @backend.send_message(message)
  end
end

class BackEnd < ZMQ::Handler
  def initialize(pollitem, backend, frontend)
    super
    @backend = backend
    @frontend = frontend
  end
  def on_readable
    message = @backend.recv_message
    @frontend.send_message(message)
  end
end

ZL.run do
  ZL.register_readable(frontend, FrontEnd, frontend, backend)
  ZL.register_readable(backend, BackEnd, backend, frontend)
end
