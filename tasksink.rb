#!/usr/bin/env ruby
require 'ffi-rzmq'

context = ZMQ::Context.new
receiver = context.socket(ZMQ::PULL)
receiver.bind('tcp://*:5558')

# wait for start:
s = ''
rc = receiver.recv_string(s)
fail if rc < 0

start_time = Time.now

100.times do |task_nbr|
  s = ''
  rc = receiver.recv_string(s)
  fail if rc < 0
  if task_nbr % 10 == 0
    print ':'
  else
    print '.'
  end
end

puts "\nTotal elapsed time: #{(Time.now - start_time) * 1000.0} milliseconds"
