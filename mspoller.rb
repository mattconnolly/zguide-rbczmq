#!/usr/bin/env ruby
require 'rbczmq'

context = ZMQ::Context.new
receiver = context.socket :PULL
receiver.connect 'tcp://localhost:5557'

subscriber = context.socket :SUB
subscriber.connect 'tcp://localhost:5556'
subscriber.subscribe "10001 "

class ReceiverHandler < ZMQ::Handler
  def on_readable
    puts "ReceiverHandler received: #{recv}"
  end
end

class SubscriberHandler < ZMQ::Handler
  def on_readable
    puts "SubscriberHandler receiver: #{recv}"
  end
end

ZL.run do
  ZL.register_readable receiver, ReceiverHandler
  ZL.register_readable subscriber, SubscriberHandler
end
