#!/usr/bin/env ruby
require 'rbczmq'
require_relative 'zmq-additions'

context = ZMQ::Context.new

def step1(context)
  xmitter = context.socket(ZMQ::PAIR)
  xmitter.connect("inproc://step2")
  puts("Step 1 ready, signalling step 2")
  xmitter.send("READY")
end

def step2(context)
  receiver = context.socket(ZMQ::PAIR)
  receiver.bind("inproc://step2")
  Thread.new { step1(context) }
  string = receiver.recv

  # connect to step 3 and tell it we're ready
  xmitter = context.socket(ZMQ::PAIR)
  xmitter.connect("inproc://step3")
  puts("Step 2 ready, signalling step 3")
  xmitter.send("READY")
end

receiver = context.socket(ZMQ::PAIR)
receiver.bind("inproc://step3")
Thread.new { step2(context) }

# Wait for signal
string = receiver.recv

puts "Test successful!"

