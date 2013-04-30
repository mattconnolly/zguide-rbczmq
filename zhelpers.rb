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
  end
end
