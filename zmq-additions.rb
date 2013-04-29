module ZMQ
  class ProxyHandler < Handler
    def initialize(poll_item, socket_one, socket_two)
      super
      @socket_one = socket_one
      @socket_two = socket_two
    end

    def on_readable
      message = @socket_one.recv_message
      @socket_two.send_message message
    end
  end

  unless ::ZMQ.methods.include? :proxy
    def self.proxy_rb(frontend, backend, capture=nil)
      # ideally, this should just call the ZMQ zmq_proxy function,
      # but it appears to be missing from the interface. This is an incomplete
      # implementation, it does nothing with the capture socket.
      loop = Loop.new
      puts loop.inspect
      poll_front = Pollitem.new(frontend, ZMQ::POLLIN)
      poll_back = Pollitem.new(backend, ZMQ::POLLIN)
      poll_front.handler = ProxyHandler.new poll_front, frontend, backend
      poll_back.handler = ProxyHandler.new poll_back, backend, frontend
      loop.register(poll_front)
      loop.register(poll_back)
      loop.start
    end
  end

end
