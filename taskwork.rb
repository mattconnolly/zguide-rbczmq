#!/usr/bin/env ruby
require 'rbczmq'

context = ZMQ::Context.new
receiver = context.socket(ZMQ::PULL)
receiver.connect('tcp://localhost:5557')

sender = context.socket(ZMQ::PUSH)
sender.connect('tcp://localhost:5558')

loop do
  s = receiver.recv
  print "#{s}."
  sleep(s.to_i/1000.0)
  sender.send("")
end
