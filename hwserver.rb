require 'ffi-rzmq'

context = ZMQ::Context.new
responder = context.socket(ZMQ::REP)
raise "Failed to create socket" unless responder
responder.bind('tcp://*:5555')

loop do
  s=""
  responder.recv_string(s)
  puts "Received Hello"
  responder.send_string("World")
  sleep 1
end
