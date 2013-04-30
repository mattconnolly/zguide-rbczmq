#!/usr/bin/env ruby
require 'rbczmq'
require_relative 'zhelpers'

NUM_CLIENTS = 10
NUM_WORKERS = 3

context = ZMQ::Context.new

class Client
  def initialize(context)
    @socket = context.socket(ZMQ::REQ)
    @socket.set_random_identity
    @socket.connect("ipc://frontend.ipc")
  end

  def run
    # Send request, get reply
    @socket.send("HELLO")
    reply = @socket.recv
    puts "Client: #{reply}"
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
    @socket.send("READY")

    loop do
      # read and save all frames until we get an empty frame
      # In this example there is only 1, but there could be more.
      #message = @socket.recv_message
      identity = @socket.recv
      empty = @socket.recv

      # get request, send reply
      request = @socket.recv
      puts("Worker: #{request}")

      reply = ZMQ::Message.new
      reply.addstr(identity)
      reply.addstr("")
      reply.addstr("OK")
      @socket.send_message(reply)

      # seems czmq doesn't like sendm with a REQ socket. `recv` is fine...
      # Constructing a multi-frame message works fine though.
      #@socket.sendm(identity)
      #@socket.sendm("")
      #@socket.send("OK")
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
      worker_id = backend.recv
      worker_queue << worker_id

      # Second frame is empty
      backend.recv

      # Third frame is READY or else a client reply identity
      client_id = backend.recv
      unless client_id == "READY"
        backend.recv # empty delimiter
        reply = backend.recv

        # send to front end
        frontend.sendm(client_id)
        frontend.sendm("")
        frontend.send(reply)

        num_clients -= 1
        break if num_clients == 0
      end

      # if we have our first worker, we can start polling front end socket
      if worker_queue.length == 1
        poller.register(front_poll_item)
      end
    end

    if poller.readables.include?(frontend)
      # Now get next client request, route to last-used worker
      # Client request is [identity][empty][request]
      client_id = frontend.recv
      frontend.recv # empty
      request = frontend.recv

      backend.sendm(worker_queue.shift)
      backend.sendm("")
      backend.sendm(client_id)
      backend.sendm("")
      backend.send(request)

      # if there are no workers left, stop polling front end socket
      if worker_queue.length == 0
        poller.remove(front_poll_item)
      end
    end

  end
end

main(context)
