#!/usr/bin/env ruby
require 'rbczmq'

context = ZMQ::Context.new

socket = context.socket(ZMQ::REP)
socket.bind("tcp://*:5555")

loop do
  begin
    buffer = socket.recv
  rescue Interrupt
    puts "W: interrupt received, killing server..."
    break
  end
end
