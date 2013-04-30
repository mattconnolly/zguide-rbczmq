#!/usr/bin/env ruby
require 'rbczmq'
require_relative 'zhelpers'

context = ZMQ::Context.new

NUM_WORKERS = 10

class Worker
  attr_accessor :socket

  def initialize(context)
    @socket = context.socket(ZMQ::DEALER)
    @socket.set_random_identity
    @socket.connect("tcp://localhost:5671")
  end

  def run
    total = 0
    loop do
      # tell the broker we're ready for work
      @socket.sendm("")
      @socket.send("Hi boss")

      # Get workload from broker, until finished
      @socket.recv #delimiter
      work = @socket.recv
      finished = (work == "Fired!")
      if finished
        puts "Completed #{total} tasks"
        break
      end
      total += 1
      sleep (rand(500)+1)/1000.0
    end
  end
end

def main(context)
  broker = context.socket(ZMQ::ROUTER)
  broker.bind("tcp://*:5671")
  NUM_WORKERS.times do
    Thread.new do
      Worker.new(context).run
    end
  end

  # run for five seconds and then tell works to end
  end_time = Time.now + 5
  workers_fired = 0

  loop do
    # next message gives us least recently used worker
    identity = broker.recv
    broker.recv # delimiter
    broker.recv # worker response

    broker.sendm(identity)
    broker.sendm("")

    # Encourage workers until it's time to fire them
    if Time.now < end_time
      broker.send("Work harder!")
    else
      broker.send("Fired!")
      workers_fired += 1
      break if workers_fired == NUM_WORKERS
    end
  end
end

main(context)
