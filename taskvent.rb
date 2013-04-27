#!/usr/bin/env ruby
require 'rbczmq'

context = ZMQ::Context.new
sender = context.socket(:PUSH)
sender.bind('tcp://*:5557')

sink = context.socket(:PUSH)
sink.connect('tcp://localhost:5558')

print "Press Enter when the workers are ready: "
gets
puts "Sending tasks to workers..."

# send start to sink
sink.send("0")

rand = Random.new(Time.now.to_i)

total_msec = 0
100.times do |task_nbr|
  workload = rand.rand(100) + 1
  total_msec += workload
  sender.send(workload.to_s)
end

puts "Total expected time: #{total_msec} milliseconds"

sleep 1
