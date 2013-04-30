require 'rbczmq'

module ZMQ
  class Socket
    def dump_messages
      loop do
        message = recv_message
        message.print
        break unless rcvmore?
      end
    end

    def set_random_identity
      self.identity = "%04X-%04X" % [rand(0x10000), rand(0x10000)]
    end
  end
end
