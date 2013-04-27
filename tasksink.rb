#!/usr/bin/env ruby
require 'rbczmq'

context = ZMQ::Context.new
receiver = context.socket(:PULL)
receiver.bind('tcp://*:5558')

# wait for start:
s = receiver.recv

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
