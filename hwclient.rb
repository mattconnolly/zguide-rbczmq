require 'ffi-rzmq'

context = ZMQ::Context.new
requester = context.socket(ZMQ::REQ)
requester.connect('tcp://localhost:5555')

10.times do |i|
  puts "Sending Hello #{i}..."
  requester.send_string("Hello")
  s=""
  requester.recv_string(s)
  puts "Received World #{i}"
end
