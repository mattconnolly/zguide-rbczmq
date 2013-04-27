#!/usr/bin/env ruby
require 'rbczmq'

context = ZMQ::Context.new
responder = context.socket(:REP)
responder.bind('tcp://*:5555')

loop do
  responder.recv
  puts "Received Hello"
  responder.send("World")
  sleep 1
end
