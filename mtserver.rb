#!/usr/bin/env ruby
require 'rbczmq'
require_relative 'zmq-additions'

context = ZMQ::Context.new

def worker(context)
  receiver = context.socket(ZMQ::REP)
  receiver.connect("inproc://workers")
  receiver.verbose = true
  loop do
    string = receiver.recv
    puts "Receiver request: [#{string}]"
    sleep 1
    receiver.send "World"
  end
end

clients = context.socket(ZMQ::ROUTER)
clients.bind("tcp://*:5555")
clients.verbose = true
workers = context.socket(ZMQ::DEALER)
workers.verbose = true
workers.bind("inproc://workers")

# create 5 workers
5.times do
  Thread.new { worker(context) }
end

ZMQ.proxy(clients, workers)
