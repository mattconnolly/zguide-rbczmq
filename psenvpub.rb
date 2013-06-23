#!/usr/bin/env ruby
require 'rbczmq'

context = ZMQ::Context.new

publisher = context.socket(ZMQ::PUB)
publisher.bind("tcp://*:5563")

loop do
  publisher.sendm("A")
  publisher.send("We don't want to see this")
  publisher.sendm("B")
  publisher.send("We would like to see this")
  sleep 1
end
