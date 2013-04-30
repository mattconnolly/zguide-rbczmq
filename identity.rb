#!/usr/bin/env ruby
require 'rbczmq'
require_relative 'zhelpers'

context = ZMQ::Context.new

sink = context.socket(ZMQ::ROUTER)
sink.bind("inproc://example")

anonymous = context.socket(ZMQ::REQ)
anonymous.connect("inproc://example")
anonymous.send("ROUTER uses a generated UUID")
sink.dump_messages

identified = context.socket(ZMQ::REQ)
identified.identity = "PEER2"
identified.connect("inproc://example")
identified.send("ROUTER socket users REQ's socket identity")
sink.dump_messages
