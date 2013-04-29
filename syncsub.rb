#!/usr/bin/env ruby
require 'rbczmq'

# run 4 instances of this script

context = ZMQ::Context.new

# First, connect our subscriber socket
subscriber = context.socket(ZMQ::SUB)
subscriber.connect("tcp://localhost:5561")
subscriber.subscribe("")

# ZMQ is so fast, we need to wait a while...
sleep(1)

# Second, synchronise with publisher
sync_client = context.socket(ZMQ::REQ)
sync_client.connect("tcp://localhost:5562")

# send a synchronise request
sync_client.send("")

# wait for synchronisation reply
sync_client.recv

# Third, get our updates and report how many we got
update_count = 0
loop do
  string = subscriber.recv
  break if string == "END"
  update_count += 1
end

puts "Received #{update_count} updates"
