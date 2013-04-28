#!/usr/bin/env ruby
require 'rbczmq'
require_relative 'zmq-additions'

context = ZMQ::Context.new

receiver = context.socket(ZMQ::PULL)
receiver.connect("tcp://localhost:5557")

sender = context.socket(ZMQ::PUSH)
sender.connect("tcp://localhost:5558")

controller = context.socket(ZMQ::SUB)
controller.connect("tcp://localhost:5559")
controller.subscribe("")

poller = ZMQ::Poller.new
receiver_poll_item = ZMQ::Pollitem.new(receiver, ZMQ::POLLIN)
controller_poll_item = ZMQ::Pollitem.new(controller, ZMQ::POLLIN)
poller.register(receiver_poll_item)
poller.register(controller_poll_item)

loop do
  poller.poll(-1) # indefinite timeout
  if poller.readables.include? receiver
    s = receiver.recv
    print "#{s}."
    sleep(s.to_i/1000.0)
    sender.send("")
  end
  if poller.readables.include? controller
    break
  end
end
