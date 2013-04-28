#!/usr/bin/env ruby
require 'rbczmq'
require_relative 'zmq-additions'

context = ZMQ::Context.new

receiver = context.socket(ZMQ::PULL)
receiver.bind("tcp://*:5558")

controller = context.socket(ZMQ::PUB)
controller.bind("tcp://*:5559")

# wait for start of batch
s = receiver.recv

# start clock
start_time = Time.now

100.times do |task_nbr|
  s = receiver.recv
  if task_nbr % 10 == 0
    print ':'
  else
    print '.'
  end
end

puts "\nTotal elapsed time: #{(Time.now - start_time) * 1000.0} milliseconds"

controller.send("KILL")
sleep(1)
