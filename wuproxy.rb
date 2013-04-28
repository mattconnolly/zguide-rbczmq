#!/usr/bin/env ruby
require 'rbczmq'
require_relative 'zmq-additions'

context = ZMQ::Context.new

# rbczmq 1.3 does not yet support XSUB or XPUB sockets

frontend = context.socket(ZMQ::XSUB)
frontend.connect("tcp://localhost:5556")

backend = context.socket(ZMQ::XPUB)
backend.connect("tcp://127.0.0.1://15556")

ZMQ.proxy(frontend, backend)
