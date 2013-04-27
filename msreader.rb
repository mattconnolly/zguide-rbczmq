#!/usr/bin/env ruby
require 'rbczmq'

context = ZMQ::Context.new
receiver = context.socket :PULL
receiver.connect 'tcp://localhost:5557'

subscriber = context.socket :SUB
subscriber.connect 'tcp://localhost:5556'
subscriber.subscribe "10001 "

loop do
  loop do
    msg = receiver.recv_nonblock
    break if msg.nil?
    # process msg
    puts "Received from PULL socket: #{msg}"
  end
  loop do
    msg = subscriber.recv_nonblock
    break if msg.nil?
    # process weather update
    puts "Weather update: #{msg}"
  end
  sleep 1
end
