module ZMQ
  class BlockHandler < ZMQ::Handler
    def initialize(pollable, block)
      super
      @block = block
    end

    def on_readable
      @block.call :read, pollitem
    end

    def on_writable
      @block.call :write, pollitem
    end

    def on_error(exception)
      @block.call :error, exception
    end
  end

  class Loop
    def self.register_readable_block(socket, &block)
      register_readable(socket, BlockHandler, block)
    end
  end

  ## Example usage:
  #ZL.register_readable_block receiver do |what, item|
  #  puts "ReceiverHandler received: #{item.recv}" if what == :read
  #end
  #
  #ZL.register_readable_block subscriber do |what, item|
  #  case what
  #    when :read
  #      puts "SubscriberHandler receiver: #{item.recv}" if what == :read
  #    else
  #      puts item.inspect
  #  end
  #end
end
