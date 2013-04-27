#!/usr/bin/env ruby
require 'rbczmq'

context = ZMQ::Context.new

requester = context.socket ZMQ::REQ
requester.connect 'tcp://localhost:5559'

10.times do |request_number|
  requester.send "Hello"
  reply = requester.recv
  puts "Received reply #{request_number} [#{reply}]"
end
