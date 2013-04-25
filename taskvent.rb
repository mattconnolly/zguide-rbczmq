#!/usr/bin/env ruby
require 'ffi-rzmq'

context = ZMQ::Context.new
sender = context.socket(ZMQ::PUSH)
sender.bind('tcp://*:5557')

sink = context.socket(ZMQ::PUSH)
sink.connect('tcp://localhost:5558')

print "Press Enter when the workers are ready: "
gets
puts "Sending tasks to workers..."

# send start to sink
sink.send_string("0")

rand = Random.new(Time.now.to_i)

total_msec = 0
100.times do |task_nbr|
  workload = rand.rand(100) + 1
  total_msec += workload
  sender.send_string(workload.to_s)
end

puts "Total expected time: #{total_msec} milliseconds"

sleep 1
