#!/usr/bin/env ruby
require 'rbczmq'

context = ZMQ::Context.new

# First, connect our subscriber socket
subscriber = context.socket(ZMQ::SUB)
subscriber.connect("tcp://localhost:5563")
subscriber.subscribe("B")

loop do
  address = subscriber.recv
  contents = subscriber.recv
  puts "[#{address}] #{contents}"
end
