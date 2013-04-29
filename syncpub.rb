#!/usr/bin/env ruby
require 'rbczmq'

context = ZMQ::Context.new

publisher = context.socket(ZMQ::PUB)
publisher.bind("tcp://*:5561")

sync_service = context.socket(ZMQ::REP)
sync_service.bind("tcp://*:5562")

puts "Waiting for subscribers"
SUBSCRIBERS_EXPECTED = 4
SUBSCRIBERS_EXPECTED.times do
  string = sync_service.recv
  sync_service.send("")
end

sleep(1)

puts "Broadcasting messages"
1_000_000.times do
  publisher.send("Rhubarb")
end
publisher.send("END")
