#!/usr/bin/env ruby
require 'rbczmq'
require_relative 'zmq-additions'

context = ZMQ::Context.new

frontend = context.socket(ZMQ::ROUTER)
frontend.bind("tcp://*:5559")

backend = context.socket(ZMQ::DEALER)
backend.bind("tcp://*:5560")

ZMQ.proxy(frontend, backend)
