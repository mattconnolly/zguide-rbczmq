#!/usr/bin/env ruby
require 'rbczmq'
require_relative 'zhelpers'

NUM_CLIENTS = 30
NUM_WORKERS = 25
WORKER_READY = "\001"

context = ZMQ::Context.new


# as per lbbroker2.rb
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

# as per lbbroker2.rb
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
      sleep 0.1
      @socket.send_message(reply)
    end
  end
end

# a helper class that calls a block when ever a pollable item is readable.
class BlockHandler < ZMQ::Handler
  def initialize(pollitem, &block)
    super
    @block = block
  end

  # handle incoming message, pass the poll item to the block
  def on_readable
    begin
      @block.call(@pollitem)
    rescue Exception => ex
      puts "Exception in BlockHandler#on_readable: #{ex}"
    end
  end

  # create a ZMQ::Pollitem with a BlockHandler set up to call the given block
  # whenever the given socket is readable.
  def self.when_readable(socket, &block)
    pollitem = ZMQ::Pollitem(socket, ZMQ::POLLIN)
    pollitem.handler = self.new(pollitem, &block)
    pollitem
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
  loop = ZMQ::Loop.new
  frontend_poll = BlockHandler.when_readable(frontend) do |pollitem|
    # executes when front end has readable messages
    message = frontend.recv_message
    message.wrap(worker_queue.shift)
    backend.send_message(message)

    # cancel reader on frontend if we went from 1 to 0 workers
    if worker_queue.empty?
      loop.remove(pollitem)
    end
  end
  backend_poll = BlockHandler.when_readable(backend) do
    # executes when back end is
    message = backend.recv_message

    # use worker identity for load balancing
    identity = message.unwrap
    worker_queue << identity

    # enable reader on front end if we went from 0 to 1 workers
    if worker_queue.count == 1
      loop.register(frontend_poll)
    end

    # forward message to client unless its just a READY
    unless message.first.data == WORKER_READY
      frontend.send_message(message)
    end
  end
  loop.register(backend_poll)
  puts "starting loop!"
  loop.start
end

main(context)
