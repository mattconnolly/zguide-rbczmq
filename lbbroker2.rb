#!/usr/bin/env ruby
require 'rbczmq'
require_relative 'zhelpers'

NUM_CLIENTS = 10
NUM_WORKERS = 3
WORKER_READY = "\001"

context = ZMQ::Context.new

class Client
  def initialize(context)
    @socket = context.socket(ZMQ::REQ)
    @socket.set_random_identity
    @socket.connect("ipc://frontend.ipc")
  end

  def run
    # Send request, get reply
    loop do
      @socket.send("HELLO")
      reply = @socket.recv
      puts "Client: #{reply}"
      sleep(1)
    end
  end
end

class Worker
  def initialize(context)
    @socket = context.socket(ZMQ::REQ)
    @socket.set_random_identity
    @socket.connect("ipc://backend.ipc")
  end

  def run
    # Tell broker we're ready for work
    @socket.send(WORKER_READY)

    loop do
      # read and save all frames until we get an empty frame
      # In this example there is only 1, but there could be more.
      message = @socket.recv_message

      puts("Worker: #{message.last}")

      reply = ZMQ::Message.new
      reply.add(message.pop)
      reply.add(message.pop)
      reply.addstr("OK")
      @socket.send_message(reply)
    end
  end
end

def main(context)
  frontend = context.socket(ZMQ::ROUTER)
  backend = context.socket(ZMQ::ROUTER)
  frontend.bind("ipc://frontend.ipc")
  backend.bind("ipc://backend.ipc")

  num_clients = 0
  NUM_CLIENTS.times do
    Thread.new do
      begin
        num_clients += 1
        client = Client.new(context)
        client.run
      rescue Exception => ex
        puts "Client thread exit with exception: #{ex}"
        puts ex.backtrace
      end
    end
  end

  NUM_WORKERS.times do
    Thread.new do
      begin
        worker = Worker.new(context)
        worker.run
      rescue Exception => ex
        puts "Worker thread exit with exception: #{ex}"
        puts ex.backtrace
      end
    end
  end

  worker_queue = []
  poller = ZMQ::Poller.new
  front_poll_item = ZMQ::Pollitem.new(frontend, ZMQ::POLLIN)
  back_poll_item = ZMQ::Pollitem.new(backend, ZMQ::POLLIN)
  poller.register(back_poll_item)
  loop do
    poller.poll(-1)

    if poller.readables.include?(backend)
      # Queue worker identity for load-balancing
      message = backend.recv_message
      worker_id = message.unwrap
      worker_queue << worker_id # save identity ZMQ::Frame

      # unless message is a WORKER_READY send to client
      unless message.first.data == WORKER_READY
        frontend.send_message(message)
      end

      # if we have our first worker, we can start polling front end socket
      if worker_queue.length == 1
        poller.register(front_poll_item)
      end
    end

    if poller.readables.include?(frontend)
      # Now get next client request, route to last-used worker
      # Client request is [identity][empty][request]
      message = frontend.recv_message
      message.wrap(worker_queue.shift)
      backend.send_message(message)

      # if there are no workers left, stop polling front end socket
      if worker_queue.length == 0
        poller.remove(front_poll_item)
      end
    end

  end
end

main(context)
