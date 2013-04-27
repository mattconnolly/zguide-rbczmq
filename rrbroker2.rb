#!/usr/bin/env ruby
require 'rbczmq'

context = ZMQ::Context.new

frontend = context.socket ZMQ::ROUTER
backend = context.socket ZMQ::DEALER
frontend.bind 'tcp://*:5559'
backend.bind 'tcp://*:5560'

require_relative 'block_handler'

ZL.run do
  ZL.register_readable_block(frontend) do |what, pollitem|
    message = frontend.recv_message
    backend.send_message(message)
  end
  ZL.register_readable_block(backend) do |what, pollitem|
    message = backend.recv_message
    frontend.send_message(message)
  end
end
