#!/usr/bin/env ruby
require 'rbczmq'

context = ZMQ::Context.new

responder = context.socket ZMQ::REP
responder.connect 'tcp://localhost:5560'

loop do
  string = responder.recv
  puts "Received request: [#{string}]"

  # do some work
  sleep 1

  # send reply back to client
  responder.send "World"
end
