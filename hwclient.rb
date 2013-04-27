#!/usr/bin/env ruby
require 'rbczmq'

context = ZMQ::Context.new
requester = context.socket(:REQ)
requester.connect('tcp://localhost:5555')

10.times do |i|
  puts "Sending Hello #{i}..."
  requester.send("Hello")
  requester.recv
  puts "Received World #{i}"
end
